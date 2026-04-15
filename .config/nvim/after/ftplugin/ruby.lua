-- Ruby gf support: resolve `require "pacon/foo"` to `lib/pacon/foo.rb`
--
-- suffixesadd: automatically try appending .rb when using gf
-- path: directories to search when resolving require paths
-- includeexpr: transform the require argument into a file path gf can find

vim.opt_local.suffixesadd:prepend(".rb")

-- Dynamically add top-level directories to path (mimics $LOAD_PATH discovery)
local root = vim.fn.getcwd()
for name, type in vim.fs.dir(root) do
  if type == "directory" and not name:match("^%.") then
    vim.opt_local.path:append(name)
  end
end

-- includeexpr: handles transforming require arguments for gf
-- Converts `require "pacon/base/foo"` -> looks up `pacon/base/foo` in path with .rb suffix
-- Also strips leading quotes/parens that Neovim might pick up
vim.opt_local.includeexpr = "substitute(v:fname, '\\v^[\"\\''(]+|[\"\\'')+]+$', '', 'g')"

-- include pattern: match both `require` and `require_relative` lines
vim.opt_local.include = [[^\s*\(require\|require_relative\)\s*['"]\zs[^'"]*]]
