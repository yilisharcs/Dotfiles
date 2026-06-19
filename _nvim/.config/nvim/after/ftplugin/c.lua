vim.bo.expandtab = true
vim.wo[0][0].colorcolumn = "100"
vim.bo.iskeyword = vim.o.iskeyword .. ",'"
vim.cmd.compiler("gcc")
