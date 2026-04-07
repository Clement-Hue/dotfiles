return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
        end,
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer local keymaps",
      },
    },
  },
}
