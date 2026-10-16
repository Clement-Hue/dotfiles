return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  dependencies = {
    {
      "smart-splits-nvim/backend-wezterm",
      main = "smart-splits-backend-wezterm",
      opts = { cli_path = "wezterm" },
    },
  },
  config = function()
    local smart_splits = require("smart-splits")

    smart_splits.setup({
      -- Preserve the previous default: wrap to the opposite Neovim split at an edge.
      move = {
        at_edge = "wrap",
      },
      mux = {
        backend = "smart-splits-backend-wezterm",
      },
    })

    -- Navigation: move between Neovim splits and wezterm panes
    vim.keymap.set({ "n", "t" }, "<C-h>", smart_splits.move_cursor_left, { desc = "Move to left split/pane" })
    vim.keymap.set({ "n", "t" }, "<C-j>", smart_splits.move_cursor_down, { desc = "Move to lower split/pane" })
    vim.keymap.set({ "n", "t" }, "<C-k>", smart_splits.move_cursor_up, { desc = "Move to upper split/pane" })
    vim.keymap.set({ "n", "t" }, "<C-l>", smart_splits.move_cursor_right, { desc = "Move to right split/pane" })

    -- Resize: swap between Neovim splits and wezterm panes
    vim.keymap.set("n", "<A-h>", smart_splits.resize_left, { desc = "Resize left" })
    vim.keymap.set("n", "<A-j>", smart_splits.resize_down, { desc = "Resize down" })
    vim.keymap.set("n", "<A-k>", smart_splits.resize_up, { desc = "Resize up" })
    vim.keymap.set("n", "<A-l>", smart_splits.resize_right, { desc = "Resize right" })
  end,
}
