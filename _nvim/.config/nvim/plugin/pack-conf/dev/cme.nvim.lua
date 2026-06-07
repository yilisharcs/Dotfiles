vim.g.cme = {
        shell = "nu",
        shell_flags = { "-m", "psql" },
        efm_rules = {
                ["buffer"] = { "just" },
                [vim.o.grepformat] = { "task" },
        },
        modifiers = {
                rg = "--vimgrep",
        },
}

vim.cmd.packadd("cme.nvim")

require("utils.cabbrev")({
        ["MXCompile"] = { "c", "C", "compile" },
        ["MXRecompile"] = { "r", "R", "recompile" },
        ["MXCompile fd --strip-cwd-prefix=never"] = { "find" },
        ["MXCompile rg"] = { "grep" },
})

vim.keymap.set("n", "<leader>c", ":MXCompile ")
vim.keymap.set("n", "<leader>C", "<CMD>MXCompile<CR>")
vim.keymap.set("n", "<leader>r", ":MXRecompile ")
vim.keymap.set("n", "<leader>R", ":MXRecompile! ")
