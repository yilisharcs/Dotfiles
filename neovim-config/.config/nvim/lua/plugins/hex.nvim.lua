return {
        "https://github.com/RaafatTurki/hex.nvim",
        lazy = false,
        init = function()
                require("utils.cabbrev")({
                        ["HexToggle"] = { "hex" },
                })
        end,
}
