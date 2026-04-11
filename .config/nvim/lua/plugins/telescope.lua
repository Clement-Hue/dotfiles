return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "gr",               "<cmd>Telescope lsp_references<cr>", nowait = true, desc = "LSP references" },
      { "<leader>ff",       "<cmd>Telescope find_files<cr>",            desc = "Find files" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>",            desc = "Find files" },
      { "<leader>fg",       "<cmd>Telescope live_grep<cr>",             desc = "Live grep" },
      { "<leader>fg",       "<cmd>Telescope grep_string<cr>",           mode = "v",                      desc = "Grep selection" },
      { "<leader>fb",       "<cmd>Telescope buffers<cr>",               desc = "Buffers" },
      { "<leader>,",        "<cmd>Telescope buffers<cr>",               desc = "Buffers (Leader-Leader)" },
      { "<leader>fh",       "<cmd>Telescope help_tags<cr>",             desc = "Help tags" },
      { "<leader>fr",       "<cmd>Telescope oldfiles<cr>",              desc = "Recent files" },
      { "<leader>fd",       "<cmd>Telescope diagnostics<cr>",           desc = "Diagnostics" },
      { "<leader>fs",       "<cmd>Telescope lsp_document_symbols<cr>",  desc = "Document symbols" },
      { "<leader>fw",       "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>gs",       "<cmd>Telescope git_status<cr>",            desc = "Git status" },
      { "<leader>gc",       "<cmd>Telescope git_commits<cr>",           desc = "Git commits" },
      { "<leader>gb",       "<cmd>Telescope git_branches<cr>",          desc = "Git branches" },
    },
    opts = function()
      local actions = require("telescope.actions")
      local common = {
        -- navigation
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        -- open
        ["<C-t>"] = actions.select_tab,  -- new tab
        ["<C-h>"] = actions.select_horizontal, -- horizontal split
        ["<C-v>"] = actions.select_vertical, -- vertical split
      }
      return {
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            preview_cutoff = 0,
          },
          mappings = {
            i = common,
            n = common,
          },
        },
        pickers = {
          buffers = {
            mappings = {
              n = {
                ["d"] = actions.delete_buffer,
              },
            },
          },
        },
      }
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("ui-select")
    end,
  }
}
