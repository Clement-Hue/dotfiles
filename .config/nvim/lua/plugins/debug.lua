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
                { id = "scopes",  size = 0.5 },
                { id = "repl",    size = 0.25 },
                { id = "console", size = 0.25 },
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
      { "<leader>de",    function() require("dapui").eval() end,                                               desc = "Eval expression",       mode = { "n", "v" } },
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
      -- Adapters
      -----------------------------------------------------------------------

      -- JS/TS (via dapDebugServer from vscode-js-debug)
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/dist/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      -- Ruby (requires 'debug' gem in Gemfile)
      dap.adapters.ruby = {
        type = "executable",
        command = "bundle",
        args = { "exec", "rdbg", "--open", "--command", "--" },
      }
      -----------------------------------------------------------------------
      -- Configurations
      -----------------------------------------------------------------------

      -- JS/TS
      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
      dap.configurations.ruby = {
        {
          type = "ruby",
          name = "Run Minitest file",
          request = "launch",
          program = "bundle",
          args = { "exec", "ruby", "${file}" },
          cwd = "${workspaceFolder}",
        },

        {
          type = "ruby",
          name = "Run Minitest line (Neotest friendly)",
          request = "launch",
          program = "bundle",
          args = function()
            return {
              "exec",
              "ruby",
              "${file}",
              "-n",
              "/" .. vim.fn.expand("<cword>") .. "/",
            }
          end,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
