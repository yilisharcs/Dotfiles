require("mini.operators").setup({
        evaluate = {
                prefix = "g=",
        },
        exchange = {
                prefix = "cx",
                reindent_linewise = true,
        },
        multiply = {
                prefix = "gm",
        },
        replace = {
                prefix = "cs",
                reindent_linewise = true,
        },
        sort = {
                prefix = "_s",
        }
})

vim.keymap.set("n", "gyy", "mzgmmkgcc`zj", { remap = true, desc = "Duplicate and comment" })
vim.keymap.set("x", "gy", "gmmzgvgc`z", { remap = true, desc = "Duplicate and comment selection" })
