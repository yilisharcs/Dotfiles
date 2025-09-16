vim.wo.list = false
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.signcolumn = "no"
vim.wo.winhighlight = "Normal:NormalNC,qfLineNr:Number"

-- FIXME: use vim.pack?
vim.cmd.packadd("cfilter")

vim.fn.matchadd("DiagnosticError", "|E|")
vim.fn.matchadd("DiagnosticWarn", "|W|")
vim.fn.matchadd("DiagnosticInfo", "|I|")
vim.fn.matchadd("DiagnosticHint", "|H|")
vim.fn.matchadd("DiagnosticError", "")
vim.fn.matchadd("DiagnosticWarn", "")
vim.fn.matchadd("DiagnosticInfo", "")
vim.fn.matchadd("DiagnosticHint", "󰞏")
