return {
  {
    'numToStr/Navigator.nvim',
    cond = not vim.g.neovide,
    keys = {
      { '<M-h>', function() require('Navigator').left() end,  mode = { 'n', 't' } },
      { '<M-j>', function() require('Navigator').down() end,  mode = { 'n', 't' } },
      { '<M-k>', function() require('Navigator').up() end,    mode = { 'n', 't' } },
      { '<M-l>', function() require('Navigator').right() end, mode = { 'n', 't' } },
    },
    opts = {}
  }
}
