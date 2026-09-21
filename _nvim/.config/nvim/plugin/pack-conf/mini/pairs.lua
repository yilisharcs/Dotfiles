require("mini.pairs").setup({
    mappings = {
        ["("] = {},
        [")"] = {},
        ["["] = {},
        ["]"] = {},
        ["{"] = {},
        ['"'] = {},
        ["'"] = false,
        ["`"] = false,
    },
})

vim.keymap.set("i", "<C-h>", "v:lua.MiniPairs.bs()", { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-w>", 'v:lua.MiniPairs.bs("\23")', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-u>", 'v:lua.MiniPairs.bs("\21")', { expr = true, replace_keycodes = false })
