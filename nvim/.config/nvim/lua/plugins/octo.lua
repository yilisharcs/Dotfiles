return {
        "pwntester/octo.nvim",
        lazy = false,
        dependencies = {
                "ibhagwan/fzf-lua",
                "nvim-tree/nvim-web-devicons",
        },
        keys = {
                { "<leader>o", "<CMD>Octo actions<CR>" }
        },
        opts = {
                picker = "fzf-lua",
                picker_config = {
                        use_emojis = true,
                },
        }
}
