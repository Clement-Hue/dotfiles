local keymap = vim.keymap.set

keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })

-- Split window (horizontal & vertical)
keymap("n", "<leader>sh", "<cmd>split<CR>")
keymap("n", "<leader>sv", "<cmd>vsplit<CR>")

keymap("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
keymap("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

keymap("x", "K", ":move '<-2<CR>gv=gv", { desc = "Move lines up" })
keymap("x", "J", ":move '>+1<CR>gv=gv", { desc = "Move lines down" })

keymap("n", "<leader>tt", "<C-w>T", { desc = "Move current split to new tab" })
keymap("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })