return {
        "https://github.com/kevinhwang91/nvim-fundo",
        name = "fundo",
        dependencies = {
                "https://github.com/kevinhwang91/promise-async",
        },
        event = "VeryLazy",
        init = function()
                vim.o.undofile = true
        end,
        opts = {},
}
