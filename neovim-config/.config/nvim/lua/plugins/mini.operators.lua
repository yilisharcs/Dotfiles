return {
        "nvim-mini/mini.operators", -- see `:h MiniOperators.config`.
        version = false,
        keys = {
                { "g=", mode = { "n", "x" } },
                { "cx", mode = { "n", "x" } },
                { "gm", mode = { "n", "x" } },
                { "cs", mode = { "n", "x" } },
        },
        init = function()
                vim.keymap.set("n", "gyy", "mzgmmkgcc`zj", { remap = true, desc = "Duplicate and comment" })
                vim.keymap.set("x", "gy", "gmmzgvgc`z", { remap = true, desc = "Duplicate and comment selection" })
        end,
        opts = {
                evaluate = {
                        prefix = "g=",
                        func = nil,
                },
                exchange = {
                        prefix = "cx",
                        reindent_linewise = true,
                },
                multiply = {
                        prefix = "gm",
                        func = nil,
                },
                replace = {
                        prefix = "cs",
                        reindent_linewise = true,
                },
                sort = {
                        prefix = ""
                }
        }
}
