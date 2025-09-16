vim.bo.expandtab = false
vim.bo.textwidth = 120
vim.wo.colorcolumn = string.format("%d", vim.bo.textwidth)

vim.treesitter.language.register("c", "lemon")
