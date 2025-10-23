require("mini.surround").setup({
        mappings = {
                add = "ys",
                delete = "yd",
                replace = "yc",
                find = "",
                find_left = "",
                highlight = "",
                update_n_lines = "",
        },
        respect_selection_type = true,
        search_method = "cover_or_next",
        custom_surroundings = {
                ["B"] = { -- Bold
                        input = { "%*%*().-()%*%*" },
                        output = { left = "**", right = "**" },
                },
                ["G"] = { -- Code block
                        input = { "%```().-()%```" },
                        output = { left = "```", right = "\n```" },
                },
        }
})

vim.keymap.del("x", "ys")
vim.keymap.set("x", "Y", ":<C-u>lua MiniSurround.add('visual')<CR>", { silent = true })
vim.keymap.set("n", "yS", "ys$", { remap = true })
vim.keymap.set("n", "yss", "ys_", { remap = true })
