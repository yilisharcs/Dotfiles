-- Update global marks automatically
vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
        group    = vim.api.nvim_create_augroup("Smart_Marks", { clear = true }),
        callback = function()
                local name = vim.api.nvim_buf_get_name(0)
                local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))

                for _, m in ipairs(vim.fn.getmarklist()) do
                        local mark, file = m.mark:sub(2, 2), m.file

                        if string.match(mark, "[%d]") ~= nil then return end

                        -- Opening a file with a global mark causes its path to be
                        -- shortened. While shada undoes this on close, it doesn't
                        -- help us any here.
                        if string.sub(file, 1, 2) == "~/" then
                                file = vim.fs.abspath(file)
                        end

                        if file == name then
                                vim.api.nvim_buf_set_mark(0, mark, lnum, col, {})
                                return
                        end
                end
        end
})
