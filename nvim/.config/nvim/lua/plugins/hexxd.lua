return {
        "RaafatTurki/hex.nvim",
        keys = {
                { "<leader>x", "<CMD>HexToggle<CR>", desc = "Toggle hex dump" },
        },
        opts = {
                -- Not too fond of this plugin trying to read files that
                -- are NOT binary or are already read by other plugins
                is_file_binary_pre_read = function()
                        return false
                end,
                is_file_binary_post_read = function()
                        return false
                end,
        }
}
