return {
        "https://github.com/tpope/vim-dispatch",
        event = "CmdlineEnter",
        init = function()
                vim.keymap.set("ca", "make", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^make") then
                                        return "Make"
                                else
                                        return "make"
                                end
                        end
                end, { expr = true })
                vim.keymap.set("ca", "mask", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^mask") then
                                        return "Make"
                                else
                                        return "mask"
                                end
                        end
                end, { expr = true })
        end,
}
