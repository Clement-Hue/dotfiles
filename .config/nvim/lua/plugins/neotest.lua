return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adapters
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>nt", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>ns", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Test suite" },
      { "<leader>nl", function() require("neotest").run.run_last() end, desc = "Test last" },
      { "<leader>no", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>nS", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-minitest"),
          require("neotest-rspec"),
          require("neotest-python"),
        },
        consumers = {
          notifications = function(client)
            client.listeners.run = function(_, root_id)
              local test_name = vim.fn.fnamemodify(root_id, ":t")
              vim.notify("Neotest started: " .. test_name, vim.log.levels.INFO, { title = "Neotest" })
            end

            client.listeners.results = function(_, results, partial)
              if partial then
                return
              end

              local counts = { passed = 0, failed = 0, skipped = 0, other = 0 }
              for _, result in pairs(results) do
                local status = result.status
                if status == "passed" then
                  counts.passed = counts.passed + 1
                elseif status == "failed" then
                  counts.failed = counts.failed + 1
                elseif status == "skipped" then
                  counts.skipped = counts.skipped + 1
                else
                  counts.other = counts.other + 1
                end
              end

              local level = counts.failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO
              local summary = string.format(
                "Neotest completed: %d passed, %d failed, %d skipped",
                counts.passed,
                counts.failed,
                counts.skipped
              )
              if counts.other > 0 then
                summary = summary .. string.format(", %d other", counts.other)
              end

              vim.notify(summary, level, { title = "Neotest" })
            end

            return {}
          end,
        },
        output_panel = {
          enabled = true,
          open = "vsplit | wincmd L",
        },
      })
    end,
  },
}
