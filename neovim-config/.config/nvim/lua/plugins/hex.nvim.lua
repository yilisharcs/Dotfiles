return {
        "https://github.com/yilisharcs/hex.nvim",
        -- branch = "undolevel",
        dev = true,
        lazy = false,
        keys = {
                {
                        "<leader>b",
                        "<CMD>Hex toggle<CR>",
                        desc = "Toggle hex dump",
                },
        },
        init = function()
                vim.g.hex = {
                        keymaps = false,
                        prettify = {
                                unicode = true,
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

                vim.keymap.set("n", "u", "<Plug>(HexUndo)", { desc = "Undo one change" })
                vim.keymap.set("n", "U", "<Plug>(HexRedo)", { desc = "Redo one change" })

                require("utils.cabbrev")({
                        ["Hex"] = { "hex" },
                })
        end,
}
