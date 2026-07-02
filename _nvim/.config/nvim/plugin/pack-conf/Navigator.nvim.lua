require("Navigator").setup({
        disable_on_zoom = true,
})

vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-h>", "<CMD>NavigatorLeft<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-l>", "<CMD>NavigatorRight<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-k>", "<CMD>NavigatorUp<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-j>", "<CMD>NavigatorDown<CR>")
