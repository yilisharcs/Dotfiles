local H = {}

H.eval = { buf = nil }

H.scratch = function()
        local buf = H.eval.buf

        if buf and vim.api.nvim_buf_is_valid(buf) then
                local win = vim.fn.bufwinid(buf)
                if win ~= -1 then
                        vim.api.nvim_win_close(win, true)
                        return
                end
        else
                buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_name(buf, "[eval]")
                vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
                vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
                vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
                vim.api.nvim_set_option_value("modified", false, { buf = buf })
                H.setup_eval(buf)
                H.eval.buf = buf
        end

        vim.cmd("tabnew")
        vim.api.nvim_win_set_buf(0, buf)
end

H.lua_pager = function(c_buf)
        local ok, ui2 = pcall(require, "vim._core.ui2")
        if ok then
                local u_b = ui2.bufs
                local u_w = ui2.wins
                for _, buf in ipairs({ u_b.pager, u_b.cmd }) do
                        if not buf or not vim.api.nvim_buf_is_valid(buf) then
                                break
                        end

                        vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
                        vim.api.nvim_set_option_value("wrap", false, { win = u_w.pager })
                        vim.api.nvim_set_option_value("wrap", false, { win = u_w.cmd })
                        vim.api.nvim_set_option_value("colorcolumn", "", { win = u_w.pager })
                        vim.api.nvim_set_option_value("colorcolumn", "", { win = u_w.cmd })
                end
        end

        local lines = vim.api.nvim_buf_get_lines(c_buf, 0, -1, false)

        local func, err = loadstring(table.concat(lines, "\n"))
        if func then
                local _, result = pcall(func)
                P(result)
        else
                P(err)
        end

        vim.api.nvim_set_option_value("modified", false, { buf = c_buf })
end

H.setup_eval = function(buf)
        vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
        vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })

        vim.api.nvim_create_autocmd("BufWriteCmd", {
                buffer = buf,
                callback = function()
                        H.lua_pager(buf)
                        vim.api.nvim_set_option_value("modified", false, { buf = buf })
                end,
        })
end

vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
                local buf = H.eval.buf
                if buf and vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_set_option_value("modified", false, { buf = buf })
                end
        end,
})

vim.keymap.set("n", "<leader>s", H.scratch, { desc = "Toggle scratch buffer" })
