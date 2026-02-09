return {
        "https://github.com/sindrets/diffview.nvim",
        cmd = "DiffviewOpen",
        keys = {
                {
                        "<leader>gl",
                        "<CMD>DiffviewFileHistory %<CR>",
                        desc = "View git file history",
                },
                {
                        "<leader>gL",
                        "<CMD>DiffviewFileHistory<CR>",
                        desc = "View git repo history",
                },
        },
        opts = function()
                local actions = require("diffview.actions")
                return {
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
                                        {
                                                "n",
                                                "<C-n>",
                                                actions.select_next_entry,
                                                {
                                                        desc = "Open next file diff",
                                                },
                                        },
                                        {
                                                "n",
                                                "<C-p>",
                                                actions.select_prev_entry,
                                                {
                                                        desc = "Open prev file diff",
                                                },
                                        },
                                },
                                file_panel = {
                                        {
                                                "n",
                                                "<C-n>",
                                                actions.select_next_entry,
                                                {
                                                        desc = "Open next file diff",
                                                },
                                        },
                                        {
                                                "n",
                                                "<C-p>",
                                                actions.select_prev_entry,
                                                {
                                                        desc = "Open prev file diff",
                                                },
                                        },
                                        {
                                                "n",
                                                "<C-k>",
                                                actions.scroll_view(-0.25),
                                                { desc = "Scroll the view up" },
                                        },
                                        {
                                                "n",
                                                "<C-j>",
                                                actions.scroll_view(0.25),
                                                {
                                                        desc = "Scroll the view down",
                                                },
                                        },
                                },
                                file_history_panel = {
                                        {
                                                "n",
                                                "<C-n>",
                                                actions.select_next_entry,
                                                {
                                                        desc = "Open next file diff",
                                                },
                                        },
                                        {
                                                "n",
                                                "<C-p>",
                                                actions.select_prev_entry,
                                                {
                                                        desc = "Open prev file diff",
                                                },
                                        },
                                        {
                                                "n",
                                                "<C-k>",
                                                actions.scroll_view(-0.25),
                                                { desc = "Scroll the view up" },
                                        },
                                        {
                                                "n",
                                                "<C-j>",
                                                actions.scroll_view(0.25),
                                                {
                                                        desc = "Scroll the view down",
                                                },
                                        },
                                },
                        },
                }
        end,
}
