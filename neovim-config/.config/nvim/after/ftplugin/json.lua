vim.bo.formatprg = "jq"

local bufname = vim.api.nvim_buf_get_name(0)
if bufname:match("%.S3AIR/") then vim.bo.commentstring = "// %s" end
