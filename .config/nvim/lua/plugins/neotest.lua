return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      -- adapters
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-python",
    },
    config = function()
      -- custom consumer that sends notifications on test start/finish
      local function notify_consumer(client)
        client.listeners.run = function()
          vim.notify("Running tests...", vim.log.levels.INFO, {
            title = "Neotest",
            icon = "🧪",
          })
        end

        client.listeners.results = function(_adapter_id, results)
          local passed, failed, skipped = 0, 0, 0
          for _, result in pairs(results) do
            if result.status == "passed" then
              passed = passed + 1
            elseif result.status == "failed" then
              failed = failed + 1
            elseif result.status == "skipped" then
              skipped = skipped + 1
            end
          end

          local msg = string.format("Passed: %d  Failed: %d  Skipped: %d", passed, failed, skipped)
          local level = failed > 0 and vim.log.levels.ERROR or vim.log.levels.INFO
          vim.notify(msg, level, { title = "Neotest" })
        end

        return {}
      end

      local neotest = require("neotest")
      neotest.setup({
        consumers = {
          notify = notify_consumer,
        },
        output_panel = {
          enabled = true,
          open = "vsplit | wincmd L",
        },
        adapters = {
          require("neotest-jest"),
          require("neotest-minitest"),
          require("neotest-rspec"),
          require("neotest-python"),
        },
      })

      local keymap = vim.keymap.set
      keymap("n", "<leader>nn", function() neotest.run.run() end, { desc = "Test nearest" })
      keymap("n", "<leader>nf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test file" })
      keymap("n", "<leader>ns", function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Test suite" })
      keymap("n", "<leader>nl", function() neotest.run.run_last() end, { desc = "Test last" })
      keymap("n", "<leader>no", function() neotest.output_panel.toggle() end, { desc = "Toggle output panel" })
      keymap("n", "<leader>nS", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
    end,
  },
}
