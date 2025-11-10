return {
        "https://github.com/yilisharcs/cme.nvim",
        dev = true,
        init = function()
                vim.g.cme = {
                        shell = "nu",
                }

                require("utils.cabbrev")({
                        ["Compile"] = { "c", "C" },
                })
        end,
}
