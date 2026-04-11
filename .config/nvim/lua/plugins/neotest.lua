return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- adapters
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-python",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-minitest"),
          require("neotest-rspec"),
          require("neotest-python"),
        },
        output_panel = {
          enabled = true,
          open = "vsplit | wincmd L",
        },
      })

      local keymap = vim.keymap.set
      keymap("n", "<leader>nt", function() neotest.run.run() end, { desc = "Test nearest" })
      keymap("n", "<leader>nf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test file" })
      keymap("n", "<leader>ns", function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Test suite" })
      keymap("n", "<leader>nl", function() neotest.run.run_last() end, { desc = "Test last" })
      keymap("n", "<leader>no", function() neotest.output_panel.toggle() end, { desc = "Toggle output panel" })
      keymap("n", "<leader>nS", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
    end,
  },
}
