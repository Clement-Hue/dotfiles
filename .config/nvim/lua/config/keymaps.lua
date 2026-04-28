local keymap = vim.keymap.set

-- Ctrl+h/j/k/l navigation handled by smart-splits.nvim (supports wezterm panes)

-- Split window (horizontal & vertical)
keymap("n", "<leader>h", "<cmd>split<CR>", { desc = "Horizontal split" })
keymap("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })


keymap("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
keymap("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

keymap("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move lines up" })
keymap("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move lines down" })

keymap("n", "<leader>tt", "<C-w>T", { desc = "Move current split to new tab" })
keymap("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })

keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

keymap("n", "<leader>rs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Rename word under cursor in buffer" })
keymap("x", "<leader>rs", [["zy:%s/<C-r>z/<C-r>z/gI<Left><Left><Left>]], { desc = "Rename selection in buffer" })
