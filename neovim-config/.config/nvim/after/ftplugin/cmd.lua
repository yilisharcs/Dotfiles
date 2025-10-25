vim.wo[0][0].linebreak = true

local ex_hl = vim.wo[0][0].winhighlight
local opt = string.gsub(ex_hl, "MsgArea", "ExTUIArea", 1)
vim.wo[0][0].winhighlight = opt
