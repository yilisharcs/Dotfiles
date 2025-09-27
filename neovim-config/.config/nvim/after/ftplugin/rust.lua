vim.b.editorconfig = false

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

vim.api.nvim_create_autocmd({ "TermOpen" }, {
        group = vim.api.nvim_create_augroup("Rust_Cargo_Jump", { clear = true }),
        pattern = "*:cargo*",
        callback = function()
                local key = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
                vim.api.nvim_feedkeys(key, "t", false)
                vim.keymap.set("n", "-", "6s> ", { remap = true, buffer = true })
        end
})

-- Although `let g:rustfmt_autosave = 1` exists,
-- running RustFmt directly populates the loclist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = vim.api.nvim_create_augroup("Rust_Auto_Fmt", { clear = true }),
        pattern = "*.rs",
        callback = function()
                -- RustFmt expects a POSIX compliant shell with shellcmdflag
                -- option set accordingly. Nushell is not POSIX compliant.
                if vim.o.shell ~= "/usr/bin/bash" then
                        local shell = vim.o.shell
                        local shellcmdflag = vim.o.shellcmdflag

                        vim.o.shell = vim.fn.exepath("bash")
                        vim.o.shellcmdflag = "-c"

                        vim.cmd("silent! RustFmt")

                        vim.o.shell = shell
                        vim.o.shellcmdflag = shellcmdflag
                        return
                end
                vim.cmd("silent! RustFmt")
        end
})
