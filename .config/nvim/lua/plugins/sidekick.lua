return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        picker = "telescope",
      },
    },
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<esc>",
        function()
          if not require("sidekick.nes").clear() then
            return "<Esc>"
          end
        end,
        expr = true,
        desc = "Clear NES or fallback",
      },
      { "<leader>aa", function() require("sidekick.cli").toggle({ name = "copilot", focus = true }) end, desc = "Sidekick Toggle CLI" },
      { "<leader>as", function() require("sidekick.cli").select() end,                                   desc = "Select CLI" },
      { "<leader>ad", function() require("sidekick.cli").close() end,                                    desc = "Detach CLI Session" },
      { "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end,                   desc = "Send This",          mode = { "x", "n" } },
      { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end,                   desc = "Send File" },
      { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end,              desc = "Send Selection",     mode = { "x" } },
      { "<leader>ap", function() require("sidekick.cli").prompt() end,                                   desc = "Sidekick Prompt",    mode = { "n", "x" } },
    },
  },
}
