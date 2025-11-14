return {
        "https://github.com/yilisharcs/cme.nvim",
        dev = true,
        init = function()
                vim.g.cme = {
                        shell = "nu",
                }

                vim.keymap.set("n", "<leader>c", ":Compile ")
                vim.keymap.set("n", "<leader><S-c>", "<CMD>Compile!<CR>")

                require("utils.cabbrev")({
                        ["Compile"] = { "c", "C" },
                        ["Compile make"] = { "make" },
                        ["Compile grep"] = { "grep" },
                        ["Compile task"] = { "task" },
                })
        end,
}
