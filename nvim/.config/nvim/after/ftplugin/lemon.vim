setlocal colorcolumn=120
setlocal noexpandtab

setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

lua vim.treesitter.language.register("c", "lemon")
