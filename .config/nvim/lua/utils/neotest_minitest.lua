return function()
  local minitest = require("neotest-minitest")
  local original_build_spec = minitest.build_spec

  -- Fix --name regex for Minitest::Spec with module namespaces.
  -- The plugin anchors with ^ but doesn't capture module/class prefixes,
  -- so the filter never matches. Removing ^ lets it match as a substring.
  minitest.build_spec = function(args)
    local spec = original_build_spec(args)
    if spec and spec.command then
      for i, arg in ipairs(spec.command) do
        if type(arg) == "string" and arg:match("^/%^") then
          spec.command[i] = "/" .. arg:sub(3)
        end
      end
    end
    if args.strategy == "dap" then
      -- spec.strategy.args = strip_initial_continue(spec.strategy.args or {})
      -- Let DAP continue once breakpoints are registered instead of
      -- auto-continuing before the attach handshake completes.
      spec.strategy.nonstop = true
    end
    return spec
  end

  return minitest
end
