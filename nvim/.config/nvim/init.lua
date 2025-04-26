vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '-', '<CMD>Ex<CR>')
vim.keymap.set('n', '<leader>ql', '<CMD>Lazy<CR>')

local nushell_ctrl_o = vim.api.nvim_buf_get_name(0)
local nushell_strlen = string.len(nushell_ctrl_o)
if string.sub(nushell_ctrl_o, 1, 5) == '/tmp/'
    and string.sub(nushell_ctrl_o, nushell_strlen - 2) == '.nu' then
  vim.g.nu_buf_editor = true
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out,                            'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ import = 'plugins' }, {
  change_detection = { notify = false },
  dev = {
    path = '~/projects/nvim',
    patterns = {},
    fallback = false,
  },
  install = {
    colorscheme = { 'lunaperche' },
  },
  ui = {
    border = 'rounded',
    backdrop = 100,
  },
})
