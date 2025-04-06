vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Fallback wincmd (navigator)
vim.keymap.set({ 'n', 't' }, '<M-h>', '<CMD>wincmd h<CR>')
vim.keymap.set({ 'n', 't' }, '<M-j>', '<CMD>wincmd j<CR>')
vim.keymap.set({ 'n', 't' }, '<M-k>', '<CMD>wincmd k<CR>')
vim.keymap.set({ 'n', 't' }, '<M-l>', '<CMD>wincmd l<CR>')

vim.keymap.set('n', '<leader>ql', '<CMD>Lazy<CR>')

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
  ui = {
    border = 'rounded',
    backdrop = 100,
  },
})
