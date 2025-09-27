return {
        "mhinz/vim-grepper",
        event = "VeryLazy",
        init = function()
                vim.g.grepper = nil
                vim.g.grepper = {
                        jump = 1,
                        searchreg = 1,
                        switch = 0,
                        quickfix = 1,
                        operator = {
                                prompt = 0,
                                tools = { "rg" },
                        },
                        rg = {
                                escape = "\\^$.*[]",
                                grepformat = "%f:%l:%c:%m",
                                grepprg = "vimgrep.nu",
                        },
                        tools = { "rg", "git", "grep" },
                }

                vim.keymap.set({ "n", "x" }, "gs", "<Plug>(GrepperOperator)")
                vim.keymap.set("ca", "grep", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^grep") then
                                        return "GrepperRg"
                                else
                                        return "grep"
                                end
                        end
                end, { expr = true })
        end
}
