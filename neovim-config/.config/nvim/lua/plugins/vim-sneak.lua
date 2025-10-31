return {
        "https://github.com/justinmk/vim-sneak",
        dependencies = {
                {
                        "yilisharcs/vim-repeat",
                        branch = "maparg",
                },
        },
        keys = {
                { "s", "<Plug>Sneak_s", mode = { "n", "x" } },
                { "S", "<Plug>Sneak_S", mode = { "n", "x" } },
                { "z", "<Plug>Sneak_s", mode = "o" },
                { "Z", "<Plug>Sneak_S", mode = "o" },
                { "f", "<Plug>Sneak_f", mode = { "n", "x", "o" } },
                { "F", "<Plug>Sneak_F", mode = { "n", "x", "o" } },
                { "t", "<Plug>Sneak_t", mode = { "n", "x", "o" } },
                { "T", "<Plug>Sneak_T", mode = { "n", "x", "o" } },
        },
        init = function()
                vim.g["sneak#use_ic_scs"] = 1

                local group = vim.api.nvim_create_augroup("SneakInsertMode", { clear = true })
                vim.api.nvim_create_autocmd("InsertEnter", {
                        group = group,
                        callback = function()
                                vim.api.nvim_set_hl(0, "Sneak", {})
                        end,
                })
                vim.api.nvim_create_autocmd({ "ColorScheme", "InsertLeave" }, {
                        group = group,
                        callback = function()
                                vim.api.nvim_set_hl(0, "Sneak", { link = "SneakShow", force = true })
                        end,
                })
                vim.api.nvim_create_autocmd("TermOpen", {
                        group = group,
                        callback = function()
                                vim.api.nvim_set_hl(0, "SneakScope", { bg = "#060010" })
                        end,
                })
        end,
}
