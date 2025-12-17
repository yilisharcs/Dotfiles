return {
        "https://github.com/zk-org/zk-nvim",
        name = "zk",
        keys = {
                { "<leader>zg", "<CMD>ZkTags<CR>", desc = "Open tags picker" },
                {
                        "<leader>zo",
                        function()
                                require("zk").edit({ sort = { "modified" } })
                        end,
                        desc = "Open notes",
                },
                {
                        "<leader>zn",
                        function()
                                vim.ui.input({ prompt = "Title: " }, function(input)
                                        if not input then return end

                                        -- stylua: ignore
                                        vim.system({
                                                "zk", "new", "--no-input",
                                                "--print-path", "--title", input,
                                        }, { text = true }, function(obj)
                                                if obj.code ~= 0 then
                                                        vim.schedule(function()
                                                                vim.notify(obj.stderr, vim.log.levels.ERROR)
                                                        end)
                                                        return
                                                end

                                                local opts = { trimempty = true }
                                                local path = vim.split(obj.stdout, "\n", opts)[1]
                                                vim.schedule(function()
                                                        vim.cmd.edit(path)
                                                        vim.api.nvim_win_set_cursor(0, { 10, 0 })
                                                end)
                                        end)
                                end)
                        end,
                        desc = "Create new note",
                },
                {
                        "<leader>zl",
                        function()
                                -- stylua: ignore
                                vim.system({
                                        "zk", "new", "--no-input",
                                        "--print-path", "--group", "journal",
                                }, { text = true }, function(obj)
                                        if obj.code ~= 0 then
                                                vim.schedule(function()
                                                        vim.notify(obj.stderr, vim.log.levels.ERROR)
                                                end)
                                                return
                                        end

                                        local opts = { trimempty = true }
                                        local path = vim.split(obj.stdout, "\n", opts)[1]
                                        vim.schedule(function()
                                                vim.cmd.edit(path)
                                        end)
                                end)
                        end,
                        desc = "Create journal entry",
                },
        },
        opts = {
                picker = "fzf_lua",
        },
}
