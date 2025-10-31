return {
        "https://github.com/pwntester/octo.nvim",
        dependencies = {
                "https://github.com/ibhagwan/fzf-lua",
        },
        lazy = false,
        keys = {
                { "<leader>o", "<CMD>Octo actions<CR>", desc = "[OCTO] Actions picker" },
        },
        opts = {
                picker = "fzf-lua",
                picker_config = {
                        use_emojis = true,
                },
        },
}
