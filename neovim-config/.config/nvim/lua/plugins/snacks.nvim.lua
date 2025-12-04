return {
        "https://github.com/folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
                {
                        "<leader>gB",
                        function()
                                Snacks.gitbrowse()
                        end,
                        desc = "Open git repo in the browser",
                },
                {
                        "<leader>n",
                        function()
                                Snacks.notifier.show_history()
                        end,
                        desc = "Notification history",
                },
                { "<leader>p", ":= dd()<LEFT>", desc = "Debug inspect" },
                {
                        "<leader>s",
                        function()
                                Snacks.scratch()
                        end,
                        desc = "Toggle scratch buffer",
                },
                {
                        "<leader>S",
                        function()
                                Snacks.scratch.select()
                        end,
                        desc = "Select scratch buffer",
                },
                {
                        "<M-q>",
                        function()
                                if vim.bo.filetype == "help" then
                                        vim.cmd.bdelete()
                                else
                                        Snacks.bufdelete.delete()
                                end
                        end,
                        desc = "Delete buffer",
                },
        },
        init = function()
                -- Debugging globals
                _G.bt = function()
                        Snacks.debug.backtrace()
                end
                _G.dd = function(...)
                        Snacks.debug.inspect(...)
                end
                vim.print = _G.dd

                -- simple lsp progress example
                vim.api.nvim_create_autocmd("LspProgress", {
                        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
                        callback = function(ev)
                                local spinner = {
                                        "⠋",
                                        "⠙",
                                        "⠹",
                                        "⠸",
                                        "⠼",
                                        "⠴",
                                        "⠦",
                                        "⠧",
                                        "⠇",
                                        "⠏",
                                }

                                local opts = {
                                        id = "lsp_progress",
                                        title = "LSP Progress",
                                        opts = function(n)
                                                -- stylua: ignore
                                                n.icon = ev.data.params.value.kind == "end" and " "
                                                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                                        end,
                                }

                                -- Prevents lspmux from throwing an error with nil title
                                local ok, status = pcall(vim.lsp.status)
                                if ok and status then
                                        -- stylua: ignore
                                        vim.notify(status, vim.log.levels.INFO, opts)
                                end
                        end,
                })
        end,
        opts = {
                bigfile = {
                        size = 1.5 * 1024 * 1024, -- 1.5MB
                },
                gitbrowse = {},
                image = {
                        enabled = vim.env.TERM == "xterm-kitty",
                        doc = {
                                inline = false,
                                max_width = 20,
                                max_height = 11,
                        },
                },
                input = {},
                notifier = {},
                quickfile = {},
                scratch = {
                        win = {
                                height = 24,
                        },
                        ft = "lua",
                },
                styles = {
                        notification_history = {
                                width = 0.9,
                                wo = { wrap = true },
                        },
                },
        },
}
