require("octo").setup({
        enable_builtin = true,
        picker = "fzf-lua",
        picker_config = {
                use_emojis = true,
        },
})

-- stylua: ignore start
vim.keymap.set(
        "n",
        "<leader>oi",
        "<CMD>Octo issue list<CR>",
        { desc = "List issues" }
)
vim.keymap.set(
        "n",
        "<leader>op",
        "<CMD>Octo pr list<CR>",
        { desc = "List pull requests" }
)
vim.keymap.set(
        "n",
        "<leader>on",
        "<CMD>Octo notification list<CR>",
        { desc = "Open notifications" }
)
vim.keymap.set(
        "n",
        "<leader>os",
        function()
                require("octo.utils").create_base_search_command({
                        include_current_repo = true
                })
        end,
        { desc = "Search repo" }
)
vim.keymap.set(
        "n",
        "<leader>od",
        "<CMD>Octo discussion list<CR>",
        { desc = "List discussions" }
)
vim.keymap.set(
        "n",
        "<leader>og",
        "<CMD>Octo gist list<CR>",
        { desc = "List gists" }
)
vim.keymap.set(
        "n",
        "<leader>or",
        "<CMD>Octo repo list<CR>",
        { desc = "List repos" }
)
vim.keymap.set(
        "n",
        "<leader>ow",
        "<CMD>Octo run list<CR>",
        { desc = "List workflow runs" }
)
vim.keymap.set(
        "n",
        "<leader>oz",
        "<CMD>Octo<CR>",
        { desc = "List all Octo actions" }
)
