return {
        "yilisharcs/wikibrowse.nvim",
        dev = true,
        config = function()
                vim.g.wikibrowse = {
                        -- lang = "pt"
                }
                -- vim.keymap.set("ca", "wiki", function()
                --         if vim.fn.getcmdtype() == ":" then
                --                 local cmd = vim.fn.getcmdline()
                --                 if cmd:match("^wiki") then
                --                         return "Wikibrowse"
                --                 else
                --                         return "wiki"
                --                 end
                --         end
                -- end, { expr = true })
        end
}
