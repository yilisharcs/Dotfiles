return {
        "RaafatTurki/hex.nvim",
        dev = true,
        lazy = false,
        keys = {
                { "<leader>b", "<CMD>Hex toggle<CR>", desc = "Toggle hex dump" },
        },
        init = function()
                vim.g.hex = {
                        prettify = {
                                unicode = false
                        },
                        -- Not too fond of this plugin trying to read files that
                        -- are NOT binary or are already read by other plugins
                        -- checkbin_pre = function()
                        --         return false
                        -- end,
                        -- checkbin_post = function()
                        --         return false
                        -- end,
                }

                vim.keymap.set("ca", "hex", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^hex") then
                                        return "Hex"
                                else
                                        return "hex"
                                end
                        end
                end, { expr = true })
        end
}
