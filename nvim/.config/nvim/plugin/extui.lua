require('vim._extui').enable({
  enable = true,
  msg = {
    pos = 'cmd',
    box = { timeout = 2500 }
  },
})

vim.o.cmdheight = 0

if vim.g.neovide then
  vim.api.nvim_create_autocmd('FocusGained', {
    group = vim.api.nvim_create_augroup('Neovide_ExTUI', { clear = false }),
    pattern = '*',
    once = true,
    callback = function()
      vim.cmd('new | close')
    end
  })
end
