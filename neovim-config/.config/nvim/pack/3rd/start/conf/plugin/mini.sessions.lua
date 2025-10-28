require("mini.sessions").setup({
        force = {
                read = false,
                write = true,
                delete = true,
        },
})

vim.keymap.set("n", "<leader>cn", function()
        local cwd = vim.fs.basename(vim.uv.cwd())
        require("mini.sessions").write(cwd .. ".vim")
end, { desc = "Make session" })
vim.keymap.set("n", "<leader>cl", function()
        require("mini.sessions").select()
end, { desc = "List sessions" })
vim.keymap.set("n", "<leader>cd", function()
        require("mini.sessions").delete()
end, { desc = "Delete session" })
