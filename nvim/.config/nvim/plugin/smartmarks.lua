-- Update global marks automatically
vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
  group    = vim.api.nvim_create_augroup("Smart_Marks", { clear = true }),
  callback = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_file = vim.api.nvim_buf_get_name(0)

    for _, mark in ipairs(vim.fn.getmarklist()) do
      local mark_filepath = vim.fn.fnamemodify(mark.file, ":p")
      if mark_filepath == current_file and mark.mark:match("[A-Z]") then
        local gmark = string.sub(tostring(mark.mark), 2, #mark.mark)
        vim.api.nvim_buf_set_mark(0, gmark, line, col, {})
      end
    end
  end
})
