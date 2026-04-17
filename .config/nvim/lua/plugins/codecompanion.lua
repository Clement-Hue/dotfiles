return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<C-a>",      "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "CodeCompanion Actions" },
      { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle CodeCompanion Chat" },
      { "<leader>cn", "<cmd>CodeCompanionChat<cr>",        mode = { "n", "v" }, desc = "New CodeCompanion Chat" },
      { "<leader>ca", "<cmd>CodeCompanionChat Add<cr>",    mode = { "v" },      desc = "Add selection to Chat" },
      { "<leader>ci", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "CodeCompanion Inline" },
    },
    opts = {
      interactions = {
        chat = {
          editor_context = {
            ["buffer"] = {
              opts = {
                -- Always sync the buffer by sharing its "diff"
                default_params = "diff",
              },
            },
          },
        },
      },
    },
  },
}
