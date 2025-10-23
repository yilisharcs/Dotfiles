vim.cmd.packadd("cfilter")
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nohlsearch")

--
vim.cmd.packadd("justify") -- Provides `map n,v _j`
vim.keymap.del({ "n", "v" }, ",gq")
