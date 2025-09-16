vim.bo.commentstring = "<!-- %s -->"
vim.cmd("setlocal iskeyword+=-,'")
vim.bo.suffixesadd = ".md,.lemon"
vim.wo.colorcolumn = "0"
vim.wo.list = false
vim.wo.relativenumber = false
vim.wo.wrap = true

-- Make time heading for zk
vim.keymap.set("n", "<F2>", "G{{O<CR>### <C-r>=strftime('%H:%M')<CR><CR>", { silent = true })

-- mini doesn't surround a line with newlines
vim.b.minisurround_config = {
        respect_selection_type = false,
}
