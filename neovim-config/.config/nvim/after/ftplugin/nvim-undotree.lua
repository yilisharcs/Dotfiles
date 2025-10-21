vim.wo[0][0].foldenable = false
vim.wo[0][0].number = false
vim.wo[0][0].relativenumber = false
vim.wo[0][0].cursorlineopt = "line"
vim.wo[0][0].winhighlight = "CursorLine:Folded"

vim.keymap.set("n", "q", "<CMD>Undotree<CR>", { buffer = true })
