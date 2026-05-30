vim.cmd.packadd("undotree")

vim.g.undotree_SplitWidth = math.floor(vim.o.columns * 0.27 + 0.5)
vim.g.undotree_WindowLayout = 4
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffCommand = "diff -u0"
vim.keymap.set("n", "<leader>u", "<CMD>UndotreeToggle<CR>", { desc = "Toggle history bar" })
