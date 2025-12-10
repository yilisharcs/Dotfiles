return {
        "https://github.com/yilisharcs/direnv.vim",
        branch = "clean-ansi-codes",
        init = function()
                vim.g.direnv_silent_load = 1
        end,
        -- dev = true,
}
