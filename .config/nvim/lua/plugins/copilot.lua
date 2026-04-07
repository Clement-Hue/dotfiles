return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Copilot Chat toggle" },
      { "<leader>ca", "<Plug>CopilotChatAddSelection", mode = "v", desc = "Add selection to chat" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "Copilot explain selection" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = "v", desc = "Copilot fix selection" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", mode = "v", desc = "Copilot review selection" },
      { "<leader>cm", "<cmd>CopilotChatModels<cr>", desc = "Copilot select model" },
      { "<leader>cx", "<cmd>CopilotChatReset<cr>", desc = "Copilot reset chat" },
      { "<leader>co", "<cmd>CopilotChatOptimize<cr>", mode = "v", desc = "Copilot optimise selection" },
    },
    opts = {
      model = "claude-opus-4.6",
    },
  },
}
