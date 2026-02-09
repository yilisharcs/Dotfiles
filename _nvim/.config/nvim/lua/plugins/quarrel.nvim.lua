return {
        "https://github.com/yilisharcs/quarrel.nvim",
        dev = true,
        cond = not vim.g.shell_editor == true,
        init = function()
                vim.g.quarrel = {
                        keymaps = true,
                }
        end,
}
