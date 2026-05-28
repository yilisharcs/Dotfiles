local first = (vim.api.nvim_buf_get_lines(0, 0, 1, false) or {})[1]
if first and first:match("^JJ: Enter a description for the ") then
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { "" })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        -- no startinsert for squash
        if first:match("combined") then
                return
        end
end
vim.cmd.startinsert()
