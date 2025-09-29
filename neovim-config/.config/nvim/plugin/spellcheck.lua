vim.keymap.set("n", "<C-s>", "<CMD>set spell!<CR>", { desc = "Toggle spell checking" })
vim.keymap.set("i", "<C-s>", "<C-g>u<ESC>[s1z=gi<C-g>u", { desc = "Fix last spelling error" })
