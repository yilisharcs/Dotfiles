return {
        "nanotee/zoxide.vim",
        event = "CmdlineEnter",
        init = function()
                vim.g.zoxide_use_select = true
        end
}
