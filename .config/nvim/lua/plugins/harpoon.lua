return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

    -- Set harpoon slots with leader + number keys (azerty: & é " ')
    vim.keymap.set("n", "<leader>&", function() harpoon:list():replace_at(1) end, { desc = "Harpoon set file 1" })
    vim.keymap.set("n", "<leader>é", function() harpoon:list():replace_at(2) end, { desc = "Harpoon set file 2" })
    vim.keymap.set("n", '<leader>"', function() harpoon:list():replace_at(3) end, { desc = "Harpoon set file 3" })
    vim.keymap.set("n", "<leader>'", function() harpoon:list():replace_at(4) end, { desc = "Harpoon set file 4" })

    -- Jump to harpoon slots with number keys (azerty: & é " ')
    vim.keymap.set("n", "&", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "é", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", '"', function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "'", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
  end,
}
