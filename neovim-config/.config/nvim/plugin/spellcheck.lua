local en = vim.fs.abspath("~/.config/nvim/spell/en.utf-8.add")
local pt = vim.fs.abspath("~/.config/nvim/spell/pt.utf-8.add")

vim.o.spellfile = table.concat({ en, pt }, ",")
vim.keymap.set("n", "<F4>", function()
        if vim.bo.spelllang ~= "pt_br" then
                vim.bo.spelllang = "pt_br"
                vim.o.spellfile = table.concat({ pt, en }, ",")
        else
                vim.bo.spelllang = "en_us"
                vim.o.spellfile = table.concat({ en, pt }, ",")
        end
        vim.notify("Language: " .. vim.bo.spelllang, vim.log.levels.INFO, {
                title = "Spell Checker",
        })
end)

vim.keymap.set("n", "<C-s>", "<CMD>set spell!<CR>", { desc = "Toggle spell checking" })
vim.keymap.set("i", "<C-s>", "<C-g>u<ESC>[s1z=gi<C-g>u", { desc = "Fix last spelling error" })
vim.keymap.set("n", "z2g", "zg2zg", { desc = "Add good word to both spell files" })
vim.keymap.set("n", "z2w", "zw2zw", { desc = "Add bad word to both spell files" })
