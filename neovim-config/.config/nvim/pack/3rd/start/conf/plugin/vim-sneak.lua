vim.pack.add({
        "https://github.com/justinmk/vim-sneak",
        {
                src = "https://github.com/yilisharcs/vim-repeat",
                version = "maparg",
        },
}, { load = true })

vim.keymap.set({ "n", "x" }, "s", "<Plug>Sneak_s")
vim.keymap.set({ "n", "x" }, "S", "<Plug>Sneak_S")
vim.keymap.set("o", "z", "<Plug>Sneak_s")
vim.keymap.set("o", "Z", "<Plug>Sneak_S")
vim.keymap.set({ "n", "x", "o" }, "f", "<Plug>Sneak_f")
vim.keymap.set({ "n", "x", "o" }, "F", "<Plug>Sneak_F")
vim.keymap.set({ "n", "x", "o" }, "t", "<Plug>Sneak_t")
vim.keymap.set({ "n", "x", "o" }, "T", "<Plug>Sneak_T")

vim.g["sneak#use_ic_scs"] = 1
