return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          layouts = {
            {
              elements = {
                { id = "stacks",      size = 0.5 },
                { id = "breakpoints", size = 0.25 },
                { id = "watches",     size = 0.25 },
              },
              size = 0.2,
              position = "left",
            },
            {
              elements = {
                { id = "scopes",  size = 0.4 },
                { id = "repl",    size = 0.4 },
                { id = "console", size = 0.2 },
              },
              size = 0.3,
              position = "bottom",
            },
          },
        },
      },
      {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps --ignore-scripts && npx gulp dapDebugServer && git checkout -- .",
      },
    },

    -- Keymaps (VS Code style)
    keys = {
      { "<F5>",          function() require("dap").continue() end,                                             desc = "Continue / Start" },
      { "<F9>",          function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle breakpoint" },
      { "<leader><F9>",  function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<F10>",         function() require("dap").step_over() end,                                            desc = "Step over" },
      { "<F11>",         function() require("dap").step_into() end,                                            desc = "Step into" },
      { "<leader><F11>", function() require("dap").step_out() end,                                             desc = "Step out" },
      { "<leader>dq",    function() require("dap").terminate() end,                                            desc = "Terminate" },
      { "<leader>dr",    function() require("dap").restart() end,                                              desc = "Restart" },
      { "<leader>du",    function() require("dapui").toggle() end,                                             desc = "Toggle DAP UI" },
      { "<leader>de",    function() require("dapui").eval(nil, { enter = true }) end,                          desc = "Eval expression",       mode = { "n", "v" } },
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -----------------------------------------------------------------------
      -- UI: auto open/close
      -----------------------------------------------------------------------
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -----------------------------------------------------------------------
      -- UI: breakpoint signs
      -----------------------------------------------------------------------
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

      -----------------------------------------------------------------------
      -- Language-specific adapters & configurations
      -----------------------------------------------------------------------
      require("plugins.debug.js")(dap)
      require("plugins.debug.ruby")(dap)
    end,
  },
}
