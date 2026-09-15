-- mini.nvim's mini.extra module provides a manpage picker which takes over the
-- current buffer; pressing "q" on such a buffer causes nvim to quit. not fun.
-- @ ~/opt/neovim/share/nvim/runtime/ftplugin/man.vim:29

vim.keymap.set("n", "q", function()
    vim.cmd("lclose")

    local bufs = 0
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buflisted and (vim.api.nvim_buf_get_name(b) ~= "" or vim.bo[b].modified) then
            bufs = bufs + 1
        end
    end

    if bufs >= 2 then
        vim.cmd("bdelete")
    else
        vim.cmd("quit")
    end
end, { buf = 0 })
