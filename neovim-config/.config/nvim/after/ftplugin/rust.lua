vim.b.editorconfig = false
vim.g.rust_recommended_style = false

vim.bo.commentstring = "// %s"
vim.bo.textwidth = 99
vim.wo[0][0].colorcolumn = "100"

require("utils.cabbrev")({
        ["Cargo"] = { "cargo" },
})
