vim.bo.commentstring = "<!-- %s -->"
vim.cmd("set formatoptions+=r")
vim.opt_local.iskeyword:append({ "-", "'" }) -- NOTE: vim.opt/_local/_global will be deprecated by v1.0
vim.bo.suffixesadd = ".md,.lemon"
vim.wo[0][0].colorcolumn = "0"
vim.wo[0][0].list = false
vim.wo[0][0].relativenumber = false
vim.wo[0][0].wrap = true

-- Make time heading for zk
vim.keymap.set("n", "<F2>", "G{{O<CR>### <C-r>=strftime('%H:%M')<CR><CR>", { silent = true })

-- mini doesn't surround a line with newlines
vim.b.minisurround_config = {
        respect_selection_type = false,
}
