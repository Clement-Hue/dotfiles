return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle file explorer" },
  },
  opts = {
    explorer = {},
  },
}
