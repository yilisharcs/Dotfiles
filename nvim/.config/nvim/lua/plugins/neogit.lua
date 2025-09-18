return {
        "yilisharcs/neogit",
        branch = "fzf-lua-winopts",
        dependencies = {
                "nvim-lua/plenary.nvim",
                "sindrets/diffview.nvim",
        },
        event = "CmdlineEnter",
        keys = {
                { "<leader>i", "<CMD>Neogit<CR>" },
        },
        init = function()
                vim.cmd([[
                        augroup Neo_Legit
                                au!
                                au Filetype NeogitCommitMessage setlocal iskeyword+=-,'
                        augroup END
                ]])
        end,
        opts = {
                graph_style = "kitty",
                integrations = {
                        fzf_lua = true,
                        snacks = false,
                }
        },
        config = function(_, opts)
                require("neogit").setup(opts)

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
                                        { "n", "<c-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                                        { "n", "<c-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                                },
                                file_history_panel = {
                                        { "n", "<C-n>", actions.select_next_entry,  { desc = "Open the diff for the next file" } },
                                        { "n", "<C-p>", actions.select_prev_entry,  { desc = "Open the diff for the previous file" } },
                                        { "n", "<c-k>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                                        { "n", "<c-j>", actions.scroll_view(0.25),  { desc = "Scroll the view down" } },
                                },
                        },
                })
        end
}
