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

local group = vim.api.nvim_create_augroup("SneakInsertMode", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function()
                vim.api.nvim_set_hl(0, "Sneak", { link = "SneakHide", force = true })
        end
})
vim.api.nvim_create_autocmd({ "ColorScheme", "InsertLeave" }, {
        group = group,
        callback = function()
                vim.api.nvim_set_hl(0, "Sneak", { link = "SneakShow", force = true })
        end
})
vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        callback = function()
                vim.api.nvim_set_hl(0, "SneakScope", { bg = "#060010" })
        end
})
