return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-q>',         '<CMD>ToggleTerm<CR>',                    mode = { 'n', 't' },          desc = '[TERM] Horizontal $CWD' },
      { '<leader><C-q>', '<CMD>ToggleTerm direction=vertical<CR>', desc = '[TERM] Vertical $CWD' },
    },
    opts = {
      -- open_mapping = '<C-q>',
      direction = 'horizontal',
      size = function(term)
        if term.direction == 'horizontal' then
          return vim.o.lines * 0.3
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
    },
  }
}
