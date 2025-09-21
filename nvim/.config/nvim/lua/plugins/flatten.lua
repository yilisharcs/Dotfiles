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
                                local yazi = vim.fn.system("ps a | grep '/tmp/yazi-1000/bulk-' | grep -v 'grep'")
                                local rebase = vim.fn.system("ps a | grep '.git/rebase' | grep -v 'grep'")

                                if yazi ~= "" or rebase ~= "" then
                                        return true
                                end
                        end
                }
        }
}
