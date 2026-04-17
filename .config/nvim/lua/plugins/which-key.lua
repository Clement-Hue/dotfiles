return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
      spec = {
        { "<leader>c",  group = "Code" },
        { "<leader>d",  group = "Debug" },
        { "<leader>f",  group = "Find" },
        { "<leader>g",  group = "Git" },
        { "<leader>gh", group = "Hunks" },
        { "<leader>n",  group = "Test" },
        { "<leader>o",  group = "OpenCode" },
        { "<leader>t",  group = "Tabs" },
        { "<leader>a",  group = "Sidekick" },
      },
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
