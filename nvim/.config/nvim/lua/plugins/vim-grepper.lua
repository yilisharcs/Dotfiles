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
                                grepprg = "rg --vimgrep",
                        },
                        tools = { "rg", "git", "grep" },
                }

                vim.keymap.set({ "n", "x" }, "gs", "<Plug>(GrepperOperator)")
                vim.keymap.set("ca", "grep", "(getcmdtype() ==# ':' && getcmdline() =~# '^grep') ? 'GrepperRg' : 'grep'",
                        { expr = true })
        end
}
