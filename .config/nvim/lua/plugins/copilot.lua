return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
      },
    },
    cmd = "Copilot",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      nes = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<C-y>",
          accept = false,
          dismiss = "<Esc>",
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          dismiss = "<C-x>",
          next = "<M-n>",
          prev = "<M-p>",
        },
      },
      panel = { enabled = false },
    },
  },
}
