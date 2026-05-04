return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 50
        end,
      },
    },
    cmd = "Copilot",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      nes = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<M-y>",
          accept = false,
          dismiss = "<Esc><Esc>",
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
