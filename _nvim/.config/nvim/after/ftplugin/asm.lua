if vim.api.nvim_buf_get_name(0):match("skdisasm") then
        vim.bo.ft = "asm68k"
        vim.b.asmsyntax = "asm68k"
end
