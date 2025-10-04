local graph_style
if vim.g.neovide then
        graph_style = "unicode"
else
        graph_style = "kitty"
end

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
        opts = {
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
        end
}
