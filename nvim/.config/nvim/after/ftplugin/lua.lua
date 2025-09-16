vim.bo.keywordprg = ":help"
vim.wo[0][0].colorcolumn = "120"

vim.keymap.set("n", "<leader><leader>x", "<CMD>write | source %<CR>", { desc = "Source config file" })
vim.keymap.set("n", "<leader><leader>c", ":lua <C-r><C-l><CR>", { desc = "Source config line" })
