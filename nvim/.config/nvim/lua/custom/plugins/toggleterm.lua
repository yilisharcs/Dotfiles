return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-q>',         '<CMD>ToggleTerm<CR>',                      mode = { 'n', 't' },            desc = '[TERM] Vertical $CWD' },
      { '<leader><C-q>', '<CMD>ToggleTerm direction=horizontal<CR>', desc = '[TERM] Horizontal $CWD' },
    },
    opts = {
      direction = 'vertical',
      size = function(term)
        if term.direction == 'horizontal' then
          return vim.o.lines * 0.4
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
    },
  }
}
