vim.pack.add({
        {
                src = "https://github.com/nvim-mini/mini.nvim",
                version = vim.version.range("*"),
        },
        "https://github.com/nvim-treesitter/nvim-treesitter",
        "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
}, { load = true })
