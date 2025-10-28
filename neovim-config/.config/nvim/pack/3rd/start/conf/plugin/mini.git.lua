require("mini.git").setup({
        job = {
                git_executable = "git",
        },
})

vim.keymap.set("ca", "git", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^git") then
                        return "Git"
                else
                        return "git"
                end
        end
end, { expr = true })

vim.keymap.set("n", "<leader>gb", "<CMD>vert Git blame -s -- %<CR><CMD>vert res 15<CR><C-w>w", { desc = "Git blame" })
vim.keymap.set(
        "n",
        "<leader>gd",
        "<CMD>diffthis<CR><CMD>vert Git show HEAD:%<CR><CMD>difft<CR><C-w>w",
        { desc = "Diff current file" }
)
