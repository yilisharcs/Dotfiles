return {
        -- https://github.com/willothy/flatten.nvim/issues/108
        -- "willothy/flatten.nvim",
        "qw457812/flatten.nvim",
        lazy = false,
        priority = 1001,
        opts = {
                nest_if_no_args = true,
                hooks = {
                        should_nest = function()
                                local denylist = {
                                        "%.git/rebase%-merge/git%-rebase%-todo$",
                                        "^/tmp/%S+%.nu$",
                                        "^/tmp/crontab%.%w+/crontab$",
                                        "^/tmp/yazi%-%d+/bulk",
                                }
                                for _, pat in ipairs(denylist) do
                                        if string.match(vim.v.argv[#vim.v.argv], pat) ~= nil then
                                                return true
                                        end
                                end
                        end
                }
        }
}
