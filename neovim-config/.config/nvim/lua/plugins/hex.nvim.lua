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
                        cmd = {
                                dump = "xxd -g 2 -u",
                        },
                        keymaps = false,
                        prettify = {
                                unicode = true,
                        },
                        extensions = {
                                "bin",
                                "so",
                                "out",
                                "tess",
                        },
                }

                vim.keymap.set("n", "u", "<Plug>(HexUndo)", { desc = "Undo one change" })
                vim.keymap.set("n", "U", "<Plug>(HexRedo)", { desc = "Redo one change" })

                require("utils.cabbrev")({
                        ["Hex"] = { "hex" },
                })
        end,
}
