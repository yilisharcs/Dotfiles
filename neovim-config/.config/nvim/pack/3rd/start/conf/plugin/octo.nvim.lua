vim.pack.add({
        "https://github.com/pwntester/octo.nvim",
        "https://github.com/ibhagwan/fzf-lua",
})

require("octo").setup({
        picker = "fzf-lua",
        picker_config = { use_emojis = true },
})

vim.keymap.set("n", "<leader>o", "<CMD>Octo actions<CR>", { desc = "[OCTO] Actions picker" })
