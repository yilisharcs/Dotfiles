return {
        "https://github.com/tpope/vim-dispatch",
        event = "CmdlineEnter",
        config = function()
                require("utils.cabbrev")({
                        ["Make"] = { "make", "mask" },
                })
        end,
}
