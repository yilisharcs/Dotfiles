if vim.g.shell_editor then
    return
end

require("mini.diff").setup({
    view = {
        style = "sign",
        signs = {
            add = "┃",
            change = "┃",
            delete = "┃",
        },
    },
})

vim.keymap.set("n", "<leader>gh", "<CMD>lua MiniDiff.toggle_overlay()<CR>", { desc = "Overlay git diff" })
