vim.pack.add({
        "https://github.com/sindrets/diffview.nvim",
}, { load = true })

local actions = require("diffview.actions")
require("diffview").setup({
        -- diff_binaries = true,
        view = {
                default = {
                        layout = "diff2_vertical",
                        winbar_info = true,
                },
                file_history = {
                        winbar_info = true,
                },
        },
        file_panel = {
                win_config = {
                        position = "right",
                        width = math.floor(vim.o.columns * 0.33 + 0.5),
                },
        },
        file_history_panel = {
                win_config = {
                        height = math.floor(vim.o.lines * 0.4),
                },
        },
        keymaps = {
                view = {
                        { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                },
                file_panel = {
                        { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                        { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<C-j>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
                },
                file_history_panel = {
                        { "n", "<C-n>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
                        { "n", "<C-p>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
                        { "n", "<C-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                        { "n", "<C-j>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
                },
        },
})

vim.keymap.set("n", "<leader>gl", "<CMD>DiffviewFileHistory %<CR>", { desc = "View git file history" })
vim.keymap.set("n", "<leader>gL", "<CMD>DiffviewFileHistory<CR>", { desc = "View git repo history" })
