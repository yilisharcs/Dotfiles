vim.cmd.packadd("hex.nvim")

vim.g.hex = {
        cmd = {
                dump = "xxd -g 2 -u",
        },
        keymaps = false,
        prettify = {
                unicode = true,
        },
        extensions = {
                "bin",
                "so",
                "out",
                "tess",
        },
}

require("utils.cabbrev")({
        ["Hex"] = { "hex" },
})

vim.keymap.set("n", "<leader>b", "<CMD>Hex toggle<CR>", { desc = "Toggle hex dump" })
vim.keymap.set("n", "u", "<Plug>(HexUndo)", { desc = "Undo one change" })
vim.keymap.set("n", "U", "<Plug>(HexRedo)", { desc = "Redo one change" })
