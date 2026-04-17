return function(dap)
  -----------------------------------------------------------------------
  -- Adapter: JS/TS (via dapDebugServer from vscode-js-debug)
  -----------------------------------------------------------------------
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

  -----------------------------------------------------------------------
  -- Configurations
  -----------------------------------------------------------------------
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
end
