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
      -- CLI keymaps
      {
        "<leader>co",
        function() require("codecompanion").toggle_cli() end,
        mode = { "n", "v" },
        desc = "Toggle Copilot CLI"
      },
      {
        "<leader>cp",
        function() require("codecompanion").cli({ prompt = true }) end,
        mode = { "n", "v" },
        desc = "Prompt Copilot CLI",
      },
      {
        "<leader>cx",
        function() require("codecompanion").cli("#{this}", { focus = false }) end,
        mode = { "n", "v" },
        desc = "Add context to Copilot CLI",
      },
      {
        "<leader>cd",
        function() require("codecompanion").cli("#{diagnostics} Can you fix these?", { focus = false, submit = true }) end,
        mode = { "n" },
        desc = "Send diagnostics to Copilot CLI",
      },
      {
        "<leader>cT",
        function()
          require("codecompanion").cli("#{terminal} Sharing the output from the terminal. Can you fix it?",
            { focus = false, submit = true })
        end,
        mode = { "n" },
        desc = "Send terminal to Copilot CLI",
      },
    },
    opts = {
      prompt_library = {
        ["MR Summary"] = {
          strategy = "chat",
          description = "Generate a merge request summary in markdown",
          opts = {
            short_name = "mr",
          },
          prompts = {
            {
              role = "user",
              content = function()
                local diff = vim.fn.system("git diff dev...HEAD")
                return string.format(
                  [[Analyze the following git diff and generate a merge request description in markdown with:
- **Summary**: what changed and why
- **Problem** : what issue does this MR address
- **Changes**: a bullet list of key changes

```diff
%s
```]],
                  diff
                )
              end,
            },
          },
        },
      },
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
          adapter = {
            name = "copilot_acp",
            model = "claude-opus-4.6",
          },
          opts = {
            ---Decorate the user message before it's sent to the LLM
            ---@param message string
            ---@param adapter CodeCompanion.Adapter
            ---@param context table
            ---@return string
            prompt_decorator = function(message, adapter, context)
              return string.format([[<prompt>%s</prompt>]], message)
            end,
          },
        },
        cli = {
          agent = "copilot_cli",
          opts = {
            reload = true,
            auto_insert = true,
          },
          agents = {
            copilot_cli = {
              cmd = "copilot",
              args = {},
              description = "GitHub Copilot CLI",
            },
          },
        },
        inline = {
          adapter = {
            name = "copilot",
            model = "claude-opus-4.6",
          },
        },
        shared = {
          keymaps = {
            always_accept = {
              callback = "keymaps.always_accept",
              description = "Always accept changes in this buffer",
              modes = { n = "gA" },
              opts = { nowait = true },
            },
            accept_change = {
              callback = "keymaps.accept_change",
              description = "Accept change",
              modes = { n = "gY" },
              opts = { nowait = true, noremap = true },
            },
            reject_change = {
              callback = "keymaps.reject_change",
              description = "Reject change",
              modes = { n = "gn" },
              opts = { nowait = true, noremap = true },
            },
            cancel = {
              description = "Cancel all pending tool calls",
              modes = { n = "gq" },
              opts = { nowait = true },
            },
          },
        },
      },
    },
  },
}
