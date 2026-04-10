local keymap = vim.keymap.set

-- Ctrl+h/j/k/l navigation handled by smart-splits.nvim (supports wezterm panes)

-- Split window (horizontal & vertical)
keymap("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
keymap("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })


keymap("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
keymap("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

keymap("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move lines up" })
keymap("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move lines down" })

keymap("n", "<leader>tt", "<C-w>T", { desc = "Move current split to new tab" })
keymap("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })