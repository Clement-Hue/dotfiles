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
          tools = {
            -- Read-only tools: no approval needed
            ["read_file"] = { opts = { require_approval_before = false } },
            ["file_search"] = { opts = { require_approval_before = false } },
            ["grep_search"] = { opts = { require_approval_before = false } },
            ["get_diagnostics"] = { opts = { require_approval_before = false } },
            ["get_changed_files"] = { opts = { require_approval_before = false } },
            -- Write/execute tools: keep approval
            ["run_command"] = { opts = { require_approval_before = true, require_cmd_approval = true } },
            ["create_file"] = { opts = { require_approval_before = true } },
            ["delete_file"] = { opts = { require_approval_before = true, allowed_in_yolo_mode = false } },
            ["insert_edit_into_file"] = {
              opts = {
                require_approval_before = { buffer = true, file = true },
                require_confirmation_after = true,
              },
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
