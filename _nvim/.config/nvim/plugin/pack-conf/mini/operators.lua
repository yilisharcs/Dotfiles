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
    },
})
require("mini.operators").make_mappings("exchange", {
    textobject = "cx",
    line = "cxx",
    selection = "X",
})
vim.keymap.set("x", "cl", "c") -- replacement for raw c, clobbered by the above

vim.keymap.set("n", "g==", "^g=$", { remap = true, desc = "Evaluate line" })

vim.keymap.set("n", "gyy", "mzgmmkgcc`zj", { remap = true, desc = "Duplicate and comment" })
vim.keymap.set("x", "gy", "gmmzgvgc`z", { remap = true, desc = "Duplicate and comment selection" })

vim.keymap.set("n", "csgn", "*``<CMD>lua MiniOperators.replace()<CR>g@gn", { desc = "Match word and replace ahead" })
vim.keymap.set("n", "csgN", "*``<CMD>lua MiniOperators.replace()<CR>g@gN", { desc = "Match word and replace behind" })
