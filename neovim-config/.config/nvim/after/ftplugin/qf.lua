vim.wo[0][0].list = false
-- vim.wo[0][0].number = false
vim.wo[0][0].relativenumber = false
vim.wo[0][0].signcolumn = "no"
vim.wo[0][0].statuscolumn = ""
vim.wo[0][0].winhighlight = "Normal:NormalNC,qfLineNr:Number"

vim.fn.matchadd("DiagnosticError", "|E|")
vim.fn.matchadd("DiagnosticWarn", "|W|")
vim.fn.matchadd("DiagnosticInfo", "|I|")
vim.fn.matchadd("DiagnosticHint", "|H|")
vim.fn.matchadd("DiagnosticError", "")
vim.fn.matchadd("DiagnosticWarn", "")
vim.fn.matchadd("DiagnosticInfo", "")
vim.fn.matchadd("DiagnosticHint", "󰞏")
