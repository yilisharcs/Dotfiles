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
