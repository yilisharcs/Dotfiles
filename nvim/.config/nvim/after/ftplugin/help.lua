vim.wo[0][0].list = false
vim.wo[0][0].signcolumn = "yes:3"

vim.keymap.set("n", "q", "<CMD>bdelete<CR>", { buffer = true })
