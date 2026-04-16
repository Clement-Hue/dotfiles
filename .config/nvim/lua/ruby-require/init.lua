--- blink.cmp source for Ruby require/require_relative path completion.
--- opts.load_paths: dirs relative to root (default: lib/, app/, config/)
--- opts.root_markers: files to find project root (default: Gemfile, .git)

local CompletionItemKind = require("blink.cmp.types").CompletionItemKind

local source = {}
local DEFAULT_ROOT_MARKERS = { "Gemfile", ".git" }
local EMPTY = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }

local require_patterns = {
  [[%f[%w](require_relative)%s*%(?%s*(['"])(.-)$]],
  [[%f[%w](require)%s*%(?%s*(['"])(.-)$]],
}

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = vim.tbl_extend("keep", opts or {}, { root_markers = DEFAULT_ROOT_MARKERS })
  self._cache = {}
  return self
end

function source:enabled()
  return vim.bo.filetype == "ruby"
end

function source:get_trigger_characters()
  return { "/", '"', "'" }
end

function source:get_load_paths(bufnr)
  local root = vim.fs.root(bufnr, self.opts.root_markers)
  if not root then return {} end
  if self._cache[root] then return self._cache[root] end

  local paths = {}
  for _, rel in ipairs(vim.split(vim.o.path, ",")) do
    local abs = root .. "/" .. rel
    if vim.fn.isdirectory(abs) == 1 then paths[#paths + 1] = abs end
  end
  if #paths == 0 then paths[1] = root end

  self._cache[root] = paths
  return paths
end

local function parse_require(context)
  local line = context.line:sub(1, context.cursor[2])
  for _, pattern in ipairs(require_patterns) do
    local req_type, _, path_so_far = line:match(pattern)
    if req_type then return req_type, path_so_far end
  end
end

function source:get_completions(context, callback)
  local req_type, path_so_far = parse_require(context)
  if not req_type then return callback(EMPTY) end

  -- Split "foo/bar/baz" into dir_part="foo/bar", prefix="baz"
  local dir_part, prefix = "", path_so_far
  local last_slash = path_so_far:match("^.*()/")
  if last_slash then
    dir_part = path_so_far:sub(1, last_slash - 1)
    prefix = path_so_far:sub(last_slash + 1)
  end

  local base_dirs = req_type == "require_relative"
      and { vim.fn.expand(("#%d:p:h"):format(context.bufnr)) }
      or self:get_load_paths(context.bufnr)

  local col = context.cursor[2]
  local edit_range = {
    start = { line = context.cursor[1] - 1, character = col - #prefix },
    ["end"] = { line = context.cursor[1] - 1, character = col },
  }

  local seen, items = {}, {}
  for _, base in ipairs(base_dirs) do
    local dir = dir_part ~= "" and (base .. "/" .. dir_part) or base
    for name, typ in vim.fs.dir(dir) do
      if name:sub(1, 1) ~= "." then
        local is_dir = typ == "directory"
        local label = is_dir and (name .. "/") or name:match("(.+)%.rb$")

        if label and not seen[label] then
          seen[label] = true
          items[#items + 1] = {
            label = label,
            kind = is_dir and CompletionItemKind.Folder or CompletionItemKind.File,
            textEdit = { newText = label, range = edit_range },
            sortText = (is_dir and "1" or "2") .. name:lower(),
            data = { full_path = dir .. "/" .. name, type = typ },
          }
        end
      end
    end
  end

  callback({ is_incomplete_forward = true, is_incomplete_backward = true, items = items })
end

function source:resolve(item, callback)
  if item.data.type == "directory" then return callback(item) end

  local ok, content = pcall(vim.fn.readfile, item.data.full_path, "", 40)
  if ok and content then
    item.documentation = { kind = "markdown", value = "```rb\n" .. table.concat(content, "\n") .. "\n```" }
  end
  callback(item)
end

return source
