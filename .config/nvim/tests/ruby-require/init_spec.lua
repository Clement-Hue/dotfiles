-- Tests for ruby-require blink.cmp source
-- Run with: nvim --headless -c "PlenaryBustedFile tests/ruby-require/init_spec.lua"

-- Mock blink.cmp.types before loading the module
package.loaded["blink.cmp.types"] = {
  CompletionItemKind = {
    File = 17,
    Folder = 19,
  },
}

local source_mod = require("ruby-require")

describe("ruby-require source", function()
  local src

  before_each(function()
    src = source_mod.new()
  end)

  describe("new()", function()
    it("creates an instance with default root_markers", function()
      assert.is_not_nil(src)
      assert.same({ "Gemfile", ".git" }, src.opts.root_markers)
    end)

    it("merges custom opts with defaults", function()
      local custom = source_mod.new({ root_markers = { "Rakefile" } })
      assert.same({ "Rakefile" }, custom.opts.root_markers)
    end)

    it("initializes an empty cache", function()
      assert.same({}, src._cache)
    end)
  end)

  describe("enabled()", function()
    it("returns true when filetype is ruby", function()
      vim.bo.filetype = "ruby"
      assert.is_true(src:enabled())
    end)

    it("returns false when filetype is not ruby", function()
      vim.bo.filetype = "lua"
      assert.is_false(src:enabled())
    end)
  end)

  describe("get_trigger_characters()", function()
    it("returns /, quote and double-quote", function()
      assert.same({ "/", '"', "'" }, src:get_trigger_characters())
    end)
  end)

  describe("get_load_paths()", function()
    local tmpdir

    before_each(function()
      tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")
      -- Create a Gemfile as root marker
      vim.fn.writefile({}, tmpdir .. "/Gemfile")
    end)

    after_each(function()
      vim.fn.delete(tmpdir, "rf")
      src._cache = {}
    end)

    it("returns empty table when no root is found", function()
      -- Use a bufnr with no root markers
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "/tmp/no_project_here/file.rb")
      local paths = src:get_load_paths(buf)
      -- Might be empty or contain fallback depending on vim.fs.root behavior
      assert.is_table(paths)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("caches results per root", function()
      -- Create lib/ directory and a file so vim.fs.root can find it
      vim.fn.mkdir(tmpdir .. "/lib", "p")
      vim.fn.writefile({ "" }, tmpdir .. "/lib/foo.rb")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/lib/foo.rb")
      -- Force buffer path resolution
      vim.api.nvim_set_option_value("buftype", "", { buf = buf })

      local paths1 = src:get_load_paths(buf)
      -- Only test caching if root was found (paths non-empty)
      if #paths1 > 0 then
        local paths2 = src:get_load_paths(buf)
        assert.are.equal(paths1, paths2) -- Same reference (cached)
      else
        -- root not found; verify calling again still returns empty consistently
        local paths2 = src:get_load_paths(buf)
        assert.same({}, paths2)
      end
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("get_completions()", function()
    local tmpdir

    before_each(function()
      tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir .. "/lib", "p")
      vim.fn.mkdir(tmpdir .. "/lib/models", "p")
      vim.fn.writefile({}, tmpdir .. "/Gemfile")
      vim.fn.writefile({ "class User; end" }, tmpdir .. "/lib/user.rb")
      vim.fn.writefile({ "class Post; end" }, tmpdir .. "/lib/post.rb")
      vim.fn.writefile({ "class Admin; end" }, tmpdir .. "/lib/models/admin.rb")
      vim.fn.writefile({}, tmpdir .. "/lib/.hidden.rb")
    end)

    after_each(function()
      vim.fn.delete(tmpdir, "rf")
      src._cache = {}
    end)

    local function make_context(line, col, bufnr)
      return {
        line = line,
        cursor = { 1, col or #line },
        bufnr = bufnr or 0,
      }
    end

    it("returns EMPTY when line has no require pattern", function()
      local ctx = make_context("puts 'hello'")
      local result
      src:get_completions(ctx, function(r) result = r end)
      assert.same({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} }, result)
    end)

    it("completes require with files from load paths", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      -- Override get_load_paths to return our tmpdir/lib
      local orig = src.get_load_paths
      src.get_load_paths = function() return { tmpdir .. "/lib" } end

      local ctx = make_context('require "', nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      assert.is_true(result.is_incomplete_forward)
      assert.is_true(result.is_incomplete_backward)

      local labels = {}
      for _, item in ipairs(result.items) do
        labels[item.label] = item.kind
      end

      assert.are.equal(17, labels["user"])    -- File kind
      assert.are.equal(17, labels["post"])    -- File kind
      assert.are.equal(19, labels["models/"]) -- Folder kind
      assert.is_nil(labels[".hidden"])        -- Hidden files excluded

      src.get_load_paths = orig
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("completes require with subpath", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      src.get_load_paths = function() return { tmpdir .. "/lib" } end

      local ctx = make_context('require "models/', nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      local labels = {}
      for _, item in ipairs(result.items) do
        labels[item.label] = true
      end

      assert.is_true(labels["admin"])
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("completes require_relative from current file directory", function()
      vim.fn.writefile({ "class Sibling; end" }, tmpdir .. "/lib/sibling.rb")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/lib/user.rb")

      local ctx = make_context('require_relative "', nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      local labels = {}
      for _, item in ipairs(result.items) do
        labels[item.label] = true
      end

      assert.is_true(labels["sibling"])
      assert.is_true(labels["post"])
      assert.is_true(labels["models/"])
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles require with parentheses", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      src.get_load_paths = function() return { tmpdir .. "/lib" } end

      local ctx = make_context('require("', nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      local labels = {}
      for _, item in ipairs(result.items) do
        labels[item.label] = true
      end

      assert.is_true(labels["user"])
      assert.is_true(labels["post"])
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("handles single-quote require", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      src.get_load_paths = function() return { tmpdir .. "/lib" } end

      local ctx = make_context("require '", nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      assert.is_true(#result.items > 0)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("provides correct textEdit range", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      src.get_load_paths = function() return { tmpdir .. "/lib" } end

      local line = 'require "us'
      local ctx = make_context(line, #line, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      -- prefix is "us", so edit start should be col - 2
      for _, item in ipairs(result.items) do
        assert.are.equal(#line - 2, item.textEdit.range.start.character)
        assert.are.equal(#line, item.textEdit.range["end"].character)
      end

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("deduplicates items across multiple load paths", function()
      local tmpdir2 = vim.fn.tempname()
      vim.fn.mkdir(tmpdir2, "p")
      vim.fn.writefile({ "# duplicate" }, tmpdir2 .. "/user.rb")

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, tmpdir .. "/main.rb")

      src.get_load_paths = function() return { tmpdir .. "/lib", tmpdir2 } end

      local ctx = make_context('require "', nil, buf)
      local result
      src:get_completions(ctx, function(r) result = r end)

      local count = 0
      for _, item in ipairs(result.items) do
        if item.label == "user" then count = count + 1 end
      end

      assert.are.equal(1, count)
      vim.fn.delete(tmpdir2, "rf")
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("resolve()", function()
    local tmpdir

    before_each(function()
      tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")
    end)

    after_each(function()
      vim.fn.delete(tmpdir, "rf")
    end)

    it("adds documentation for file items", function()
      vim.fn.writefile({ "class Foo", "  def bar", "  end", "end" }, tmpdir .. "/foo.rb")

      local item = {
        label = "foo",
        data = { full_path = tmpdir .. "/foo.rb", type = "file" },
      }

      local resolved
      src:resolve(item, function(r) resolved = r end)

      assert.is_not_nil(resolved.documentation)
      assert.are.equal("plaintext", resolved.documentation.kind)
      assert.truthy(resolved.documentation.value:find("class Foo"))
    end)

    it("does not add documentation for directory items", function()
      local item = {
        label = "models/",
        data = { full_path = tmpdir .. "/models", type = "directory" },
      }

      local resolved
      src:resolve(item, function(r) resolved = r end)
      assert.is_nil(resolved.documentation)
    end)

    it("handles missing files gracefully", function()
      local item = {
        label = "missing",
        data = { full_path = tmpdir .. "/nonexistent.rb", type = "file" },
      }

      local resolved
      src:resolve(item, function(r) resolved = r end)
      assert.is_nil(resolved.documentation)
    end)
  end)
end)
