vim.cmd.startinsert()

-- In honor of Neogit
vim.keymap.set({ "n", "i" }, "<C-c><C-c>", "<CMD>wq<CR>", { buffer = true })
vim.keymap.set({ "n", "i" }, "<C-c><C-k>", "<CMD>q!<CR>", { buffer = true })
