return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = true,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 35,
        mappings = {
          ["<C-r>"] = "noop",

          ["yf"] = {
            function(state)
              local node = state.tree:get_node()
              local name = node.name
              vim.fn.setreg("+", name)
              vim.notify("Copied filename: " .. name)
            end,
            desc = "Copy filename",
          },

          ["yp"] = {
            function(state)
              local node = state.tree:get_node()
              local path = vim.fn.fnamemodify(node:get_id(), ":.")
              vim.fn.setreg("+", path)
              vim.notify("Copied relative path: " .. path)
            end,
            desc = "Copy relative path",
          },

          ["yP"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path)
              vim.notify("Copied absolute path: " .. path)
            end,
            desc = "Copy absolute path",
          },
        },
      },
    },
  },
}
