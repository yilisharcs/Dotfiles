vim.wo[0][0].colorcolumn = "80"
vim.opt_local.iskeyword:remove({ "-" })
vim.bo.commentstring = '" %s'

vim.keymap.set(
        "n",
        "<leader><leader>x",
        "<CMD>write | source %<CR>",
        { desc = "Source config file" }
)
vim.keymap.set(
        "n",
        "<leader><leader>c",
        ":.<CR>",
        { desc = "Source config line" }
)
vim.keymap.set(
        "x",
        "<leader><leader>c",
        '"zy:<C-r>z<CR><ESC>',
        { desc = "Source config line" }
)
