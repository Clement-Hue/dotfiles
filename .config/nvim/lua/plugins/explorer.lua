return {
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      { "<leader>e", function() require("snacks").explorer() end, desc = "Toggle file explorer" },
      { "<leader>nh", function() require("snacks").notifier.show_history() end, desc = "Notification history" },
    },
    opts = {
      explorer = {},
      notifier = { enabled = true, top_down = false, margin = { bottom = 2, right = 1 } },
    },
  },
}
