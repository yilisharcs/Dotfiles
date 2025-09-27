vim.bo.commentstring = "// %s"

vim.keymap.set("ca", "cargo", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^cargo") then
                        return "Cargo"
                else
                        return "cargo"
                end
        end
end, { expr = true })

-- augroup Rust_C_Plug
--   au!
--   " Jump to file error; requires vim-sneak
--   au TermOpen *:cargo* lua vim.keymap.set('n', '-', '6s> ', { remap = true, buffer = true })
-- augroup END

vim.b.editorconfig = false
