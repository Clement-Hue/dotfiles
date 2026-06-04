local function copy_to_system_clipboard(value, label)
  vim.fn.setreg("+", value)
  vim.notify(("Copied %s: %s"):format(label, value))
end

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
          ["y"] = {
            "noop",
            nowait = false,
            desc = "Path actions",
          },
          ["yy"] = {
            "copy_to_clipboard",
            desc = "Copy node for paste",
          },

          ["yf"] = {
            function(state)
              local node = state.tree:get_node()
              copy_to_system_clipboard(node.name, "filename")
            end,
            desc = "Copy filename",
          },

          ["yp"] = {
            function(state)
              local node = state.tree:get_node()
              local path = vim.fn.fnamemodify(node:get_id(), ":.")
              copy_to_system_clipboard(path, "relative path")
            end,
            desc = "Copy relative path",
          },

          ["yP"] = {
            function(state)
              local node = state.tree:get_node()
              copy_to_system_clipboard(node:get_id(), "absolute path")
            end,
            desc = "Copy absolute path",
          },
        },
      },
    },
  },
}
