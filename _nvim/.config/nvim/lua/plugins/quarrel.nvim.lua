return {
        "https://github.com/yilisharcs/quarrel.nvim",
        dev = true,
        cond = not vim.g.shell_editor == true,
        init = function()
                ---@type quarrel.Opts
                vim.g.quarrel = {
                        notify = true,
                }
        end,
}
