require("mini.diff").setup({
        view = {
                style = "sign",
                signs = { add = "┃", change = "┃", delete = "┃" },
        },
})

vim.keymap.set("n", "<leader>gh", "<CMD>lua MiniDiff.toggle_overlay()<CR>", { desc = "[Git] Diff overlay" })
