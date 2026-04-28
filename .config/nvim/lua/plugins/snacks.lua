return {
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      { "<leader>nh", function() require("snacks").notifier.show_history() end, desc = "Notification history" },
    },
    opts = {
      notifier = {
        enabled = true,
        top_down = false,
        margin = { bottom = 2, right = 1 },
      },
    },
  },
}
