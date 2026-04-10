return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>e", function() require("snacks").explorer() end, desc = "Toggle file explorer" },
  },
  opts = {
    explorer = {},
  },
}
