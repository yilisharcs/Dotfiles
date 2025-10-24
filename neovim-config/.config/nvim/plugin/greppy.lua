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

        if not start.pos or not limit.pos then return end

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
        vim.cmd("silent grep -F " .. args)
end

vim.keymap.set({ "n", "x" }, "gs", function()
        vim.o.operatorfunc = "v:lua.Greppy"
        return "g@"
end, { expr = true, desc = "Greppy operator" })

vim.keymap.set("ca", "grep", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^grep") then
                        return "silent grep"
                else
                        return "grep"
                end
        end
end, { expr = true, desc = "Fallback grep command" })
