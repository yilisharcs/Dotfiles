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
        }
})

vim.keymap.set("n", "<leader>i", "<CMD>Neogit<CR>", { desc = "[Git] Open status tab" })

---

local actions = require("diffview.actions")
require("diffview").setup({
        -- diff_binaries = true,
        view = {
                default = {
                        layout = "diff2_vertical"
                }
        },
        file_panel = {
                win_config = {
                        position = "right",
                        width = math.floor(vim.o.columns * 0.33 + 0.5),
                },
        },
        keymaps = {
                view = {
                        { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                },
                file_panel = {
                        { "n", "<C-n>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
                        { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<C-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                },
                file_history_panel = {
                        { "n", "<C-n>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
                        { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<C-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                },
        },
})
