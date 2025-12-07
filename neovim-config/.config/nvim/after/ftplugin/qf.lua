vim.wo[0][0].list = false
vim.wo[0][0].relativenumber = false
vim.wo[0][0].signcolumn = "no"
vim.wo[0][0].statuscolumn = ""
vim.wo[0][0].wrap = false

vim.wo[0][0].winhighlight = "Normal:QuickFixBg"

vim.fn.matchadd("DiagnosticError", [[^\zsE\ze|]])
vim.fn.matchadd("DiagnosticWarn", [[^\zsW\ze|]])
vim.fn.matchadd("DiagnosticInfo", [[^\zs\(I\|N\)\ze|]])
vim.fn.matchadd("DiagnosticHint", [[^\zsH\ze|]])
