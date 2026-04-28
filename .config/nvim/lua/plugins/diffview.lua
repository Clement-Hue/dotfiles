return {
  "dlyongemallo/diffview.nvim",
  opts = function()
    local actions = require("diffview.actions")
    return {
      keymaps = {
        view = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          { "n", "<leader>b", false },
        },
        file_panel = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          { "n", "<leader>b", false },
        },
        file_history_panel = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          { "n", "<leader>b", false },
        },
      },
    }
  end,
}
