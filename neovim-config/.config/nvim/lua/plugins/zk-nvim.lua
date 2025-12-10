return {
        "https://github.com/zk-org/zk-nvim",
        name = "zk",
        keys = {
                { "<leader>zg", "<CMD>ZkTags<CR>", desc = "Open tags picker" },
                {
                        "<leader>zn",
                        function()
                                vim.ui.input({ prompt = "Task: " }, function(input)
                                        if not input then return end

                                        local cmd = { "task", "add", "--print-path" }
                                        local fargs = vim.split(input, " ", { trimempty = true })
                                        for _, v in ipairs(fargs) do
                                                table.insert(cmd, v)
                                        end

                                        vim.system(cmd, { text = true }, function(obj)
                                                if obj.code ~= 0 then
                                                        vim.schedule(function()
                                                                -- stylua: ignore
                                                                vim.notify(obj.stderr, vim.log.levels.ERROR)
                                                        end)
                                                        return
                                                end

                                                local opts = { trimempty = true }
                                                local path = vim.split(obj.stdout, "\n", opts)[1]
                                                vim.schedule(function()
                                                        vim.cmd.edit(path)
                                                        vim.api.nvim_win_set_cursor(0, { 7, 0 })
                                                end)
                                        end)
                                end)
                        end,
                        desc = "Create new task",
                },
                {
                        "<leader>zl",
                        function()
                                -- HACK: The lsp complains if I don't do this directly
                                vim.system({
                                        "zk",
                                        "new",
                                        "--no-input",
                                        "--print-path",
                                        "-W",
                                        vim.fs.joinpath(vim.env.ZK_NOTEBOOK_DIR, "journal"),
                                        "--group",
                                        "journal",
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
