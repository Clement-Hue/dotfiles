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

      -- Ruby rdbg (requires 'debug' gem in Gemfile)
      -- Launches rdbg with a Unix socket, then connects via DAP pipe transport.
      dap.adapters.ruby = function(callback, config)
        local sock_path = "/run/user/1001/rdbg-" .. vim.fn.getpid()
        os.remove(sock_path)

        local env_parts = {}
        for k, v in pairs(config.env or {}) do
          table.insert(env_parts, k .. "=" .. vim.fn.shellescape(v))
        end
        local env_prefix = #env_parts > 0 and table.concat(env_parts, " ") .. " " or ""

        local cmd = env_prefix
          .. "rdbg --command --open --stop-at-load"
          .. " --sock-path=" .. sock_path
          .. " -- bundle exec ruby "
          .. (config.script or "bin/server.rb")

        local stdout = vim.loop.new_pipe(false)
        local stderr = vim.loop.new_pipe(false)

        local handle
        handle = vim.loop.spawn("bash", {
          args = { "-l", "-c", cmd },
          cwd = config.cwd or vim.fn.getcwd(),
          detached = true,
          stdio = { nil, stdout, stderr },
        }, function(code)
          if handle then handle:close() end
          stdout:close()
          stderr:close()
          if code ~= 0 then
            vim.schedule(function()
              vim.notify("rdbg exited with code " .. code, vim.log.levels.WARN)
            end)
          end
        end)

        -- Forward stdout/stderr to DAP REPL so server logs are visible
        local function forward(pipe)
          pipe:read_start(function(_, data)
            if data then
              vim.schedule(function() require("dap.repl").append(data) end)
            end
          end)
        end
        forward(stdout)
        forward(stderr)

        vim.defer_fn(function()
          callback({ type = "pipe", pipe = sock_path })
        end, 2000)
      end
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
          name = "Launch pacon server",
          request = "launch",
          script = "bin/server.rb",
          useBundler = true,
          localfs = true,
          env = {
            PACON2_ENVIRONMENT = "development",
            PACON2_HTTP_ENABLED = "enabled",
            PACON2_AMQP_ENABLED = "disabled",
            PACON2_HIBERNATUS_ENABLED = "enabled",
            PACON2_HTTP_PORT = "8080",
          },
        },
      }
    end,
  },
}
