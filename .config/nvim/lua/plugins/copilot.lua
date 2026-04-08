return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
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
