require("mini.align").setup()

vim.keymap.set({ "n", "x" }, "g<leader>a", "ga", { desc = "Print ASCII value of character under cursor" })
