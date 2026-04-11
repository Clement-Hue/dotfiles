return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
      },
      {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps --ignore-scripts && npx gulp dapDebugServer",
      },
    },
    keys = {
      { "<F5>",      function() require("dap").continue() end,         desc = "Continue / Start" },
      { "<F10>",     function() require("dap").step_over() end,        desc = "Step over" },
      { "<F11>",     function() require("dap").step_into() end,        desc = "Step into" },
      { "<S-F11>",   function() require("dap").step_out() end,         desc = "Step out" },
      { "<S-F5>",    function() require("dap").terminate() end,        desc = "Terminate" },
      { "<C-S-F5>",  function() require("dap").restart() end,          desc = "Restart" },
      { "<F9>",      function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<S-F9>",    function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end,        desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end,          desc = "Eval expression", mode = { "n", "v" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

      -- JS/TS adapter (via dapDebugServer from vscode-js-debug)
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

      -- JS/TS configurations
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

      -- Ruby adapter (requires 'debug' gem: gem install debug)
      dap.adapters.ruby = function(callback, config)
        callback({
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "bundle",
            args = {
              "exec", "rdbg", "-n", "--open", "--port", "${port}",
              "-c", "--", "bundle", "exec", config.command, config.script,
            },
          },
        })
      end

      dap.configurations.ruby = {
        {
          type = "ruby",
          name = "Debug current file",
          request = "attach",
          localfs = true,
          command = "ruby",
          script = "${file}",
        },
        {
          type = "ruby",
          name = "Run current spec file",
          request = "attach",
          localfs = true,
          command = "rspec",
          script = "${file}",
        },
      }
    end,
  },
}
