return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "dlyongemallo/diffview.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  build = function()
    require("gitlab.server").build(true)
  end,
  keys = {
    { "<leader>glc", function() require("gitlab").choose_merge_request() end, desc = "Choose Merge Request", },
    { "<leader>glr", function() require("gitlab").review() end,               desc = "Review current MR" },
  },
  config = function()
    require("gitlab").setup({
      connection_settings = {
        remote = "upstream",
      },
    })
  end,
}
