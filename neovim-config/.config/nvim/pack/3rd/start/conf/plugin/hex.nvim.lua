vim.g.hex = {
        keymaps = false,
        prettify = {
                unicode = false
        },
}

vim.pack.add({
        "https://github.com/RaafatTurki/hex.nvim",
})

vim.keymap.set("n", "<leader>b", "<CMD>Hex toggle<CR>", { desc = "Toggle hex dump" })

-- vim.keymap.set("n", "u", "<Plug>(HexUndo)", { desc = "Undo one change" })
-- vim.keymap.set("n", "U", "<Plug>(HexRedo)", { desc = "Redo one change which was undone" })

vim.keymap.set("ca", "hex", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^hex") then
                        return "Hex"
                else
                        return "hex"
                end
        end
end, { expr = true })
