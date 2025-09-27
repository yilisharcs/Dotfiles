return {
        "lambdalisue/suda.vim",
        init = function()
                vim.keymap.set("ca", "sudo", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^sudo") then
                                        return "SudaWrite"
                                else
                                        return "sudo"
                                end
                        end
                end, { expr = true })
        end
}
