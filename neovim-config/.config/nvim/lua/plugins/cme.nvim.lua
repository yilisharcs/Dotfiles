return {
        "https://github.com/yilisharcs/cme.nvim",
        dev = true,
        init = function()
                vim.g.cme = {
                        shell = "nu",
                }

                vim.keymap.set("n", "<leader>c", ":Compile ")
                vim.keymap.set("n", "<leader><S-c>", "<CMD>Compile<CR>")
                vim.keymap.set("n", "<leader>r", ":Recompile ")

                require("utils.cabbrev")({
                        ["Compile"] = { "c", "C", "compile" },
                        ["Recompile"] = { "r", "R", "recompile" },
                        ["Compile fd --strip-cwd-prefix=never"] = { "find" },
                        ["Compile git"] = { "git" },
                        ["Compile grep"] = { "grep" },
                        ["Compile make"] = { "make" },
                        ["Compile task"] = { "task" },
                        ["Compile cargo"] = { "cargo" },
                })
        end,
}
