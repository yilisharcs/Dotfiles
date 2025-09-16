vim.bo.keywordprg = ":help"
vim.bo.textwidth = 120
vim.wo[0][0].colorcolumn = string.format("%d", vim.bo.textwidth)

vim.keymap.set("n", "<leader><leader>x", "<CMD>write | source %<CR>", { desc = "Source config file" })
vim.keymap.set("n", "<leader><leader>c", ":lua <C-r><C-l><CR>", { desc = "Source config line" })
