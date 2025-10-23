vim.pack.add({
        "https://github.com/kevinhwang91/nvim-fundo",
        "https://github.com/kevinhwang91/promise-async",
})

require("fundo").setup()
vim.o.undofile = true
