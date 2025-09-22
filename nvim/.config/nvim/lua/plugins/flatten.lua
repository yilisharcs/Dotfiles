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
                                local argv = vim.v.argv
                                if argv[3] == nil then return end

                                local denylist = {
                                        "%.git/rebase%-merge/git%-rebase%-todo$",
                                        "^/tmp/%S+%.nu$",
                                        "^/tmp/bash%-fc%.%w+$",
                                        "^/tmp/crontab%.%w+/crontab$",
                                        "^/tmp/yazi%-%d+/bulk",
                                }

                                for _, pat in ipairs(denylist) do
                                        if string.match(argv[3], pat) ~= nil then
                                                return true
                                        end
                                end
                        end
                }
        }
}
