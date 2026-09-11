if vim.fn.expand("%:e") == "asm" then
        vim.bo.ft = "asm68k"
        vim.b.asmsyntax = "asm68k"
end
