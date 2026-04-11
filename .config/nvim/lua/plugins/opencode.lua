return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    keys = {
      { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask OpenCode" },
      { "<leader>os", function() require("opencode").select() end,                          mode = { "n", "x" }, desc = "OpenCode select" },
      { "<leader>ot", function() require("opencode").toggle() end,                          mode = { "n", "t" }, desc = "Toggle OpenCode" },
      { "<leader>oo", function() return require("opencode").operator("@this ") end,         mode = { "n", "x" }, desc = "Send range to OpenCode", expr = true },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {}
      vim.o.autoread = true
    end,
  },
}
