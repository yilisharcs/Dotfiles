require("which-key").setup({
        win = {
                border = "solid",
        },
})

vim.keymap.set("n", "<leader>?", function()
        require("which-key").show({ global = false })
end, { desc = "List buffer-local keymaps" })
