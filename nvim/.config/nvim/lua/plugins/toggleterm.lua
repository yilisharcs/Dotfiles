return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    lazy = false,
    keys = {
      {
        '<C-.>',
        '<CMD>exe v:count1 . "ToggleTerm"<CR>',
        mode = { 'n', 'i', 't' },
        desc = 'Toggle terminal window'
      },
    },
    opts = {
      size = function(term)
        if term.direction == 'horizontal' then
          return vim.o.lines * 0.4
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.5
        end
      end,
    }
  }
}
