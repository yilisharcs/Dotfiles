return {
        "https://github.com/yilisharcs/wikibrowse.nvim",
        dev = true,
        init = function()
                vim.g.wikibrowse = {
                        -- lang = "pt"
                }

                vim.keymap.set("ca", "wiki", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^wiki") then
                                        return "Wikibrowse"
                                else
                                        return "wiki"
                                end
                        end
                end, { expr = true })
        end,
}
