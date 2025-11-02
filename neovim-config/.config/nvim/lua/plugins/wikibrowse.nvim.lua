return {
        "https://github.com/yilisharcs/wikibrowse.nvim",
        dev = true,
        init = function()
                vim.g.wikibrowse = {
                        -- lang = "pt"
                }

                require("utils.cabbrev")({
                        ["Wikibrowse"] = { "wiki" },
                })
        end,
}
