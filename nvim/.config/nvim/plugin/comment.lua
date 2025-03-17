local function comment_above_or_below(lnum)
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local comment_row = row + lnum
  local l_cms, r_cms = string.match(vim.bo.commentstring, '(.*)%%s(.*)')
  vim.api.nvim_buf_set_lines(0, comment_row, comment_row, false, { l_cms .. r_cms })
  vim.api.nvim_win_set_cursor(0, { comment_row + 1, 0 })
  vim.api.nvim_command('normal! ==')
  vim.api.nvim_win_set_cursor(0, { comment_row + 1, #vim.api.nvim_get_current_line() - #r_cms - 1 })
  vim.api.nvim_feedkeys('a', 'ni', true)
end

vim.keymap.set('n', 'gco', function()
  comment_above_or_below(0)
end)

vim.keymap.set('n', 'gcO', function()
  comment_above_or_below(-1)
end)

vim.cmd([[
  nmap gcap gcip
  nmap gcA oz<ESC>gcckJfzcl
  nmap gc$ i<CR><ESC>gcck$J
]])
