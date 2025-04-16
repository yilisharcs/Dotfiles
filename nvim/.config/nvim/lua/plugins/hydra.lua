return {
  {
    'nvimtools/hydra.nvim',
    keys = { '<C-w>', 'z' },
    config = function()
      local hydra = require('hydra')

      hydra({
        name = 'SIDE SCROLL',
        mode = 'n',
        body = 'z',
        heads = {
          { 'h',     '5zh', {} },
          { 'l',     '5zl', { desc = '<= =>' } },
          { 'H',     'zH',  {} },
          { 'L',     'zL',  { desc = 'Half screen <= =>' } },
          { '<C-c>', nil,   { exit = true } },
        }
      })

      hydra({
        name = 'WINCMD',
        mode = 'n',
        body = '<C-w>',
        heads = {
          { '<',     '<C-w>2<',            {} },
          { '>',     '<C-w>2>',            { desc = 'Horizontal resize' } },
          { '-',     '<C-w>2-',            {} },
          { '+',     '<C-w>2+',            { desc = 'Vertical resize' } },
          { 'h',     '<C-w>h',             {} },
          { 'l',     '<C-w>l',             {} },
          { 'j',     '<C-w>j',             {} },
          { 'k',     '<C-w>k',             { desc = 'Jump' } },
          { 'H',     '<C-w>H',             {} },
          { 'L',     '<C-w>L',             {} },
          { 'J',     '<C-w>J',             {} },
          { 'K',     '<C-w>K',             { desc = 'Move' } },
          { 't',     '<CMD>tab split<CR>', {} },
          { 's',     '<C-w>s',             {} },
          { 'v',     '<C-w>v',             { desc = 'Split' } },
          { '=',     '<C-w>=',             {} },
          { 'c',     '<C-w>c',             { desc = 'Close' } },
          { '<C-c>', nil,                  { exit = true } },
        },
      })
    end,
  }
}
