--- Custom blink.cmp source for Ruby require/require_relative path completion.
--- Completes from configurable load path directories for `require`
--- and from the current file directory for `require_relative`.
--- Strips .rb extensions and filters out non-Ruby files.
---
--- Configuration (in blink.cmp providers):
---   ruby_require = {
---     name = "Ruby Require",
---     module = "ruby-require",
---     opts = {
---       -- Explicit list of directories relative to project root.
---       -- If set, skips auto-detection entirely.
---       load_paths = { "lib", "app/models", "app/services" },
---
---       -- Files/dirs used to find the project root (default: Gemfile, .git)
---       root_markers = { "Gemfile", ".git" },
---     },
---   }
---
--- Auto-detection (when load_paths is not set):
---   Scans the project root for common Ruby directories:
---   lib/, app/models/, app/controllers/, app/services/, app/jobs/,
---   app/mailers/, app/helpers/, app/

local async = require("blink.cmp.lib.async")
local CompletionItemKind = require("blink.cmp.types").CompletionItemKind

local source = {}

-- Directories to check when auto-detecting (relative to project root).
-- Order matters: first match wins for deduplication.
local AUTO_DETECT_PATHS = {
  "lib",
  "app",
  "config",
}

local DEFAULT_ROOT_MARKERS = { "Gemfile", ".git" }

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = opts or {}
  self.opts.root_markers = self.opts.root_markers or DEFAULT_ROOT_MARKERS
  -- load_paths: nil means auto-detect, or a table of strings like { "lib", "app" }
  return self
end

function source:enabled()
  return vim.bo.filetype == "ruby"
end

function source:get_trigger_characters()
  return { "/", '"', "'" }
end

--- Find the project root for a buffer.
--- @return string|nil
function source:find_root(bufnr)
  return vim.fs.root(bufnr, self.opts.root_markers)
end

--- Get the list of absolute load path directories for a buffer.
--- Results are cached per project root.
--- @return string[]
function source:get_load_paths(bufnr)
  local root = self:find_root(bufnr)
  if not root then return {} end

  -- Cache per root to avoid scanning every keystroke
  self._cache = self._cache or {}
  if self._cache[root] then return self._cache[root] end

  local paths = {}
  local candidates = self.opts.load_paths or AUTO_DETECT_PATHS

  for _, rel_path in ipairs(candidates) do
    local abs = root .. "/" .. rel_path
    if vim.fn.isdirectory(abs) == 1 then
      table.insert(paths, abs)
    end
  end

  -- Always include the project root as a last resort
  if #paths == 0 then
    table.insert(paths, root)
  end

  self._cache[root] = paths
  return paths
end

--- Try multiple patterns to match require/require_relative with parens or spaces.
local require_patterns = {
  [[%f[%w](require_relative)%s*%(%s*(['"])(.-)$]],
  [[%f[%w](require_relative)%s+(['"])(.-)$]],
  [[%f[%w](require)%s*%(%s*(['"])(.-)$]],
  [[%f[%w](require)%s+(['"])(.-)$]],
}

--- Parse the line to extract require type and the partial path typed so far.
--- @return string|nil req_type "require" or "require_relative"
--- @return string|nil path_so_far
local function parse_require(context)
  local line_to_cursor = context.line:sub(1, context.cursor[2])

  for _, pattern in ipairs(require_patterns) do
    local req_type, _, path_so_far = line_to_cursor:match(pattern)
    if req_type then return req_type, path_so_far end
  end
  return nil
end

--- Build a single completion item from a directory entry.
local function make_item(entry, scan_path, edit_range)
  local is_dir = entry.type == "directory"
  local name = entry.name

  if not is_dir then
    if not name:match("%.rb$") then return nil end
    name = name:sub(1, -4) -- strip .rb
  end

  local label = is_dir and (name .. "/") or name
  return {
    label = label,
    kind = is_dir and CompletionItemKind.Folder or CompletionItemKind.File,
    insertText = label,
    textEdit = { newText = label, range = edit_range },
    sortText = (is_dir and "1" or "2") .. name:lower(),
    data = { path = entry.name, full_path = scan_path .. "/" .. entry.name, type = entry.type },
  }
end

--- Async scan a directory, skipping hidden files.
local function scan_dir(dir_path)
  return async.task.new(function(resolve, reject)
    vim.uv.fs_scandir(dir_path, function(err, req)
      if err or not req then return reject(err) end
      local entries = {}
      while true do
        local name, entry_type = vim.uv.fs_scandir_next(req)
        if not name then break end
        if name:sub(1, 1) ~= "." then
          table.insert(entries, { name = name, type = entry_type })
        end
      end
      resolve(entries)
    end)
  end)
end

local EMPTY = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }

function source:get_completions(context, callback)
  callback = vim.schedule_wrap(callback)

  local req_type, path_so_far = parse_require(context)
  if not req_type then return callback(EMPTY) end

  -- Split "pacon/base/sto" into dir_part="pacon/base" and prefix="sto"
  local dir_part, prefix = "", path_so_far
  local last_slash = path_so_far:match("^.*()/")
  if last_slash then
    dir_part = path_so_far:sub(1, last_slash - 1)
    prefix = path_so_far:sub(last_slash + 1)
  end

  -- Determine which directories to scan
  local base_dirs
  if req_type == "require_relative" then
    base_dirs = { vim.fn.expand(("#%d:p:h"):format(context.bufnr)) }
  else
    base_dirs = self:get_load_paths(context.bufnr)
  end

  -- Collect all existing scan paths (base_dir + dir_part)
  local scan_paths = {}
  for _, base in ipairs(base_dirs) do
    local full = dir_part ~= "" and (base .. "/" .. dir_part) or base
    if vim.fn.isdirectory(full) == 1 then
      table.insert(scan_paths, full)
    end
  end

  if #scan_paths == 0 then return callback(EMPTY) end

  local col = context.cursor[2]
  local edit_range = {
    start = { line = context.cursor[1] - 1, character = col - #prefix },
    ["end"] = { line = context.cursor[1] - 1, character = col },
  }

  -- Scan all matching directories and merge results (deduplicate by label)
  local pending = #scan_paths
  local seen = {}
  local all_items = {}

  for _, scan_path in ipairs(scan_paths) do
    scan_dir(scan_path)
      :map(function(entries)
        for _, entry in ipairs(entries) do
          local item = make_item(entry, scan_path, edit_range)
          if item and not seen[item.label] then
            seen[item.label] = true
            table.insert(all_items, item)
          end
        end
        pending = pending - 1
        if pending == 0 then
          callback({ is_incomplete_forward = true, is_incomplete_backward = true, items = all_items })
        end
      end)
      :catch(function()
        pending = pending - 1
        if pending == 0 then
          if #all_items > 0 then
            callback({ is_incomplete_forward = true, is_incomplete_backward = true, items = all_items })
          else
            callback(EMPTY)
          end
        end
      end)
  end
end

function source:resolve(item, callback)
  if item.data.type == "directory" then return callback(item) end

  async.task.new(function(resolve, reject)
    vim.uv.fs_open(item.data.full_path, "r", 438, function(err, fd)
      if err or not fd then return reject(err) end
      vim.uv.fs_read(fd, 1024, 0, function(read_err, data)
        vim.uv.fs_close(fd, function() end)
        if read_err or not data then return reject(read_err) end
        resolve(data)
      end)
    end)
  end)
    :map(function(content)
      item.documentation = {
        kind = "markdown",
        value = "```rb\n" .. content .. "```",
      }
      callback(item)
    end)
    :catch(function() callback(item) end)
end

return source
