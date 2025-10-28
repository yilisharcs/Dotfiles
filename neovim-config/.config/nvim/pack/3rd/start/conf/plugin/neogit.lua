vim.pack.add({
        {
                src = "https://github.com/yilisharcs/neogit",
                version = "fzf-lua-winopts",
        },
        "https://github.com/sindrets/diffview.nvim",
        "https://github.com/ibhagwan/fzf-lua",
        "https://github.com/nvim-lua/plenary.nvim",
}, { load = true })

local graph_style
if vim.g.neovide then
        graph_style = "unicode"
else
        graph_style = "kitty"
end

require("neogit").setup({
        graph_style = graph_style,
        disable_hint = true,
        integrations = {
                fzf_lua = true,
                snacks = false,
        },
        commit_editor = {
                kind = "split",
                show_staged_diff = false,
        },
})

vim.keymap.set("n", "<leader>i", "<CMD>Neogit<CR>", { desc = "[Git] Open status tab" })
