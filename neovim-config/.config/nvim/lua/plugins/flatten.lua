return {
        -- https://github.com/willothy/flatten.nvim/issues/108
        -- "willothy/flatten.nvim",
        "qw457812/flatten.nvim",
        dependencies = { "akinsho/toggleterm.nvim" },
        lazy = false,
        priority = 1001,
        opts = function()
                local term = require("toggleterm.terminal")

                ---@type Terminal?
                local saved_terminal
                return {
                        nest_if_no_args = true,
                        window = { open = "alternate" },
                        block_for = {
                                crontab   = true,
                                gitcommit = true,
                                gitrebase = true,
                        },
                        hooks = {
                                should_nest = function()
                                        -- FIXME: Missing check for toggleterm vs builtin.
                                        -- These hooks are getting in the way of success.
                                        local default_term_denylist = {
                                                "%.git/COMMIT_EDITMSG$",
                                                "%.git/rebase%-merge/git%-rebase%-todo$",
                                                "^/tmp/crontab%.%w+/crontab$",
                                        }
                                        local toggleterm_denylist   = {
                                                "^/tmp/%S+%.nu$",
                                                "^/tmp/yazi%-%d+/bulk",
                                        }
                                        for _, pat in ipairs(toggleterm_denylist) do
                                                if string.match(vim.v.argv[#vim.v.argv], pat) ~= nil then
                                                        return true
                                                end
                                        end
                                end,
                                pre_open = function()
                                        local termid   = term.get_focused_id()
                                        saved_terminal = term.get(termid)
                                end,
                                post_open = function(opts)
                                        local bufnr, winnr, ft, is_blocking, is_diff =
                                            opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff

                                        if is_blocking and saved_terminal then
                                                saved_terminal:close()
                                        elseif not is_diff then
                                                vim.api.nvim_set_current_win(winnr)
                                        end

                                        if vim.tbl_contains({
                                                    "crontab",
                                                    "gitrebase",
                                                    "gitcommit",
                                            }, ft) then
                                                vim.api.nvim_create_autocmd("BufWritePost", {
                                                        buffer = bufnr,
                                                        callback = vim.schedule_wrap(function()
                                                                vim.api.nvim_buf_delete(bufnr, {})
                                                        end),
                                                })
                                        end
                                end,
                                block_end = function()
                                        vim.schedule(function()
                                                if saved_terminal then
                                                        saved_terminal:open()
                                                        saved_terminal = nil
                                                end
                                        end)
                                end,
                        }
                }
        end
}
