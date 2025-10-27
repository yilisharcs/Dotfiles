vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
        desc = "Update global marks automatically",
        group = vim.api.nvim_create_augroup("SmartMarks", { clear = true }),
        callback = function()
                local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
                local ascii_A = 65
                local ascii_Z = 90
                for i = ascii_A, ascii_Z do
                        local mark = string.char(i)
                        local row = vim.api.nvim_buf_get_mark(0, mark)[1]
                        if row ~= 0 then vim.api.nvim_buf_set_mark(0, mark, lnum, col, {}) end
                end
        end,
})
