return {
        -- https://github.com/willothy/flatten.nvim/issues/108
        -- "https://github.com/willothy/flatten.nvim",
        "https://github.com/qw457812/flatten.nvim",
        dependencies = {
                "https://github.com/akinsho/toggleterm.nvim",
        },
        priority = 1001,
        lazy = false,
        opts = function()
                local saved_term
                local term = require("toggleterm.terminal")
                return {
                        nest_if_no_args = true,
                        window = { open = "alternate" },
                        block_for = {
                                crontab = true,
                                gitcommit = true,
                                gitrebase = true,
                        },
                        hooks = {
                                should_nest = function()
                                        local denylist = {
                                                arg0 = {
                                                        "^/tmp/%S+%.nu$",
                                                        "^/tmp/crontab%.%w+/crontab$",
                                                        "^/tmp/yazi%-%d+/bulk",
                                                        "^/tmp/editor%-%w+.jjdescription$",
                                                        "%.git/COMMIT_EDITMSG$",
                                                        "%.git/rebase%-merge/git%-rebase%-todo$",
                                                },
                                                arg1 = {
                                                        "^/tmp/git%-blob%-%w+/",
                                                },
                                        }
                                        for _, pat in ipairs(denylist.arg0) do
                                                if string.match(vim.v.argv[#vim.v.argv], pat) ~= nil then
                                                        return true
                                                end
                                        end
                                        for _, pat in ipairs(denylist.arg1) do
                                                if string.match(vim.v.argv[#vim.v.argv - 1], pat) ~= nil then
                                                        return true
                                                end
                                        end
                                end,
                                pre_open = function()
                                        local termid = term.get_focused_id()
                                        saved_term = term.get(termid)
                                end,
                                post_open = function(opts)
                                        local bufnr, winnr, ft, is_blocking, is_diff =
                                                opts.bufnr, opts.winnr, opts.filetype, opts.is_blocking, opts.is_diff
                                        if is_blocking and saved_term then
                                                saved_term:close()
                                        elseif not is_diff then
                                                vim.api.nvim_set_current_win(winnr)
                                        end
                                        if
                                                vim.tbl_contains({
                                                        "crontab",
                                                        "gitrebase",
                                                        "gitcommit",
                                                }, ft)
                                        then
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
                                                if saved_term then
                                                        saved_term:open()
                                                        saved_term = nil
                                                end
                                        end)
                                end,
                        },
                }
        end,
}
