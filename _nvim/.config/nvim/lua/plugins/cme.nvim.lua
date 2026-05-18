return {
        "https://github.com/yilisharcs/cme.nvim",
        dev = true,
        init = function()
                vim.g.cme = {
                        shell = "nu",
                        sudo_prompt = true,
                        efm_rules = {
                                ["buffer"] = { "just" },
                                [vim.o.grepformat] = { "task" },
                        },
                }

                vim.keymap.set("n", "<leader>c", ":Compile ")
                vim.keymap.set("n", "<leader><S-c>", "<CMD>Compile<CR>")
                vim.keymap.set("n", "<leader>r", ":Recompile ")
                vim.keymap.set("n", "<leader>R", ":Recompile! ")

                require("utils.cabbrev")({
                        ["Compile"] = { "c", "C", "compile" },
                        ["Recompile"] = { "r", "R", "recompile" },
                        ["Compile fd --strip-cwd-prefix=never"] = { "find" },
                        ["Compile make"] = { "make" },
                        ["Compile rg --vimgrep"] = { "grep" },
                })

                vim.keymap.set("n", "<leader>w", function()
                        package.loaded["cme"] = nil
                        package.loaded["cme.efm"] = nil
                        print()
                end)
        end,
}
