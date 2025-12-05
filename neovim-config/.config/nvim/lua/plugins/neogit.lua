local graph_style
if vim.g.neovide then
        graph_style = "unicode"
else
        graph_style = "kitty"
end

return {
        "https://github.com/NeogitOrg/neogit",
        dependencies = {
                "https://github.com/ibhagwan/fzf-lua",
                "https://github.com/nvim-lua/plenary.nvim",
                "https://github.com/sindrets/diffview.nvim",
        },
        cmd = "Neogit",
        keys = {
                {
                        "<leader>i",
                        "<CMD>Neogit<CR>",
                        desc = "Open git status tab",
                },
        },
        init = function()
                vim.api.nvim_create_autocmd({ "User" }, {
                        pattern = "VeryLazy",
                        once = true,
                        callback = function()
                                if package.loaded["which-key"] ~= nil then
                                        vim.api.nvim_create_autocmd({ "FileType" }, {
                                                pattern = {
                                                        "NeogitPopup",
                                                        "NeogitStatus",
                                                },
                                                callback = function()
                                                        require("which-key.buf").clear()
                                                end,
                                        })
                                end
                        end,
                })
        end,
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
}
