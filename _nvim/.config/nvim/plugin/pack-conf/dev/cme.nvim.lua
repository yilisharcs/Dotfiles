local efm = {}

-- rust {{{
efm.rust = table.concat({
        "%-G",
        "%-Gerror: aborting %.%#",
        "%-Gerror: Could not compile %.%#",
        "%Eerror: %m",
        "%Eerror[E%n]: %m",
        "%Wwarning: %m",
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

local shell_flags = {
        bash = {},
        nu = { "-m", "psql" },
}

local shell = "bash"

vim.g.cme = {
        shell = shell,
        shell_flags = shell_flags[shell],
        efm_rules = {
                ["buffer"] = { "just" },
                [efm.rust] = { "cargo", "just" },
                [vim.o.grepformat] = { "task", "./lua/tafsk/init.lua" },
        },
        modifiers = {
                rg = "--vimgrep",
        },
        syntax = {
                git = { "git logr" },
                jj = {
                        "jj l",
                        -- summary
                        "jj",
                        "jj log",
                        "jj ls",
                        "jj lsa",
                        "jj lsh",
                },
        },
}

vim.cmd.packadd("cme.nvim")

require("utils.cabbrev")({
        ["MXCompile"] = { "C", "compile" },
        ["MXRecompile"] = { "R", "recompile" },
        ["MXCompile fd --strip-cwd-prefix=never"] = { "find" },
        ["MXCompile rg"] = { "grep" },
})

vim.keymap.set("n", "<leader>c", ":MXCompile ")
vim.keymap.set("n", "<leader>C", "<CMD>MXCompile<CR>")
vim.keymap.set("n", "<leader>r", ":MXRecompile ")
vim.keymap.set("n", "<leader>R", ":MXRecompile! ")
vim.keymap.set("n", "<leader>X", "<CMD>MXKill<CR>")

function Greppy(mode)
        local start = {}
        local limit = {}
        if mode == "line" or mode == "block" then
                start.mark = "<"
                limit.mark = ">"
        elseif mode == "char" then
                start.mark = "["
                limit.mark = "]"
        end
        start.pos = vim.api.nvim_buf_get_mark(0, start.mark)
        limit.pos = vim.api.nvim_buf_get_mark(0, limit.mark)

        if not start.pos or not limit.pos then
                return
        end

        local text = {}
        start.row, start.col = start.pos[1], start.pos[2]
        limit.row, limit.col = limit.pos[1], limit.pos[2]
        local lines = vim.api.nvim_buf_get_lines(0, start.row - 1, limit.row, false)

        if mode == "line" then
                text = lines
        elseif mode == "block" then
                start.block = math.min(start.col, limit.col)
                limit.block = math.max(start.col, limit.col)
                for _, line_content in ipairs(lines) do
                        table.insert(text, line_content:sub(start.block + 1, limit.block + 1))
                end
        elseif mode == "char" then
                if #lines == 1 then
                        table.insert(text, lines[1]:sub(start.col + 1, limit.col + 1))
                else
                        table.insert(text, lines[1]:sub(start.col + 1))
                        for i = 2, #lines - 1 do
                                table.insert(text, lines[i])
                        end
                        table.insert(text, lines[#lines]:sub(1, limit.col + 1))
                end
        end

        local args = table.concat(text, "\n")
        args = vim.fn.shellescape(args)

        vim.cmd(("MXCompile rg -F %s"):format(args))
end

vim.keymap.set({ "n", "x" }, "gs", function()
        vim.o.operatorfunc = "v:lua.Greppy"
        return "g@"
end, { expr = true, desc = "Greppy operator" })
