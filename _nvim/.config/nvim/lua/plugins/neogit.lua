return {
        "https://github.com/NeogitOrg/neogit",
        dependencies = {
                "https://github.com/ibhagwan/fzf-lua",
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
                                                        "gitrebase",
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
                graph_style = "kitty",
                disable_hint = true,
                integrations = {
                        fzf_lua = true,
                        snacks = false,
                },
                commit_editor = {
                        kind = "split",
                        show_staged_diff = false,
                },
                mappings = {
                        commit_editor = {
                                ["<c-c><c-c>"] = false,
                                ["<c-c><c-k>"] = false,
                        },
                        commit_editor_I = {
                                ["<c-c><c-c>"] = false,
                                ["<c-c><c-k>"] = false,
                        },
                        rebase_editor = {
                                ["<c-c><c-c>"] = false,
                                ["<c-c><c-k>"] = false,
                        },
                        rebase_editor_I = {
                                ["<c-c><c-c>"] = false,
                                ["<c-c><c-k>"] = false,
                        },
                },
        },
}
