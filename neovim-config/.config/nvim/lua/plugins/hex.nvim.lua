return {
        "https://github.com/RaafatTurki/hex.nvim",
        lazy = false,
        init = function()
                require("utils.cabbrev")({
                        ["HexToggle"] = { "hex" },
                })
        end,
        opts = {
                -- Not too fond of this plugin trying to read files that
                -- are NOT binary or are already read by other plugins
                is_file_binary_pre_read = function()
                        return false
                end,
                is_file_binary_post_read = function()
                        return false
                end,
        },
}
