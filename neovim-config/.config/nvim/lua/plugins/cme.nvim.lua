local efm = {}

-- rust {{{
efm.rust = table.concat({
        "%-G",
        "%-Gerror: aborting %.%#",
        "%-Gerror: Could not compile %.%#",
        "%Eerror: %m",
        "%Eerror[E%n]: %m",
        "%Wwarning: %m",
        -- Custom {{{
        "%Wwarning[E%n]: %m", -- Unsafe
        "%C %#╭▸ %f:%l:%c", -- Nightly rustc-unicode
        -- }}}
        "%Inote: %m",
        "%C %#--> %f:%l:%c",
        "%E  left:%m",
        "%C right:%m %f:%l:%c",
        "%Z",
        "%f:%l:%c: %t%*[^:]: %m",
        "%f:%l:%c: %*\\d:%*\\d %t%*[^:]: %m",
        "%-G%f:%l %s",
        "%-G%*[ ]^",
        "%-G%*[ ]^%*[~]",
        "%-G%*[ ]...",
        -- "%-G%\\s%#Downloading%.%#",
        -- "%-G%\\s%#Checking%.%#",
        -- "%-G%\\s%#Compiling%.%#",
        -- "%-G%\\s%#Finished%.%#",
        "%-G%\\s%#error: Could not compile %.%#",
        "%-G%\\s%#To learn more\\",
        "%.%#",
        "%-G%\\s%#For more information about this error\\",
        "%.%#",
        "%-Gnote: Run with `RUST_BACKTRACE=%.%#",
        "%.%#panicked at \\'%m\\'\\",
        "%f:%l:%c",
}, ",")
-- }}}

return {
        "https://github.com/yilisharcs/cme.nvim",
        dev = true,
        init = function()
                vim.g.cme = {
                        shell = "nu",
                        efm_rules = {
                                ["buffer"] = { "mask" },
                                [efm.rust] = { "cargo", "mask" },
                                [vim.o.grepformat] = { "task" },
                        },
                }

                vim.keymap.set("n", "<leader>c", ":Compile ")
                vim.keymap.set("n", "<leader><S-c>", "<CMD>Compile<CR>")
                vim.keymap.set("n", "<leader>r", ":Recompile ")
                vim.keymap.set("n", "<leader>R", "<CMD>Recompile!<CR>")

                require("utils.cabbrev")({
                        ["Compile"] = { "c", "C", "compile" },
                        ["Recompile"] = { "r", "R", "recompile" },
                        ["Compile fd --strip-cwd-prefix=never"] = { "find" },
                })

                vim.keymap.set("n", "<leader>w", function()
                        package.loaded["cme"] = nil
                        package.loaded["cme.efm"] = nil
                        print()
                end)
        end,
}
