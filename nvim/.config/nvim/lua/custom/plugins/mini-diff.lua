return {
  {
    'echasnovski/mini.diff', -- see `:h MiniDiff.config`.
    version = false,
    event = { 'BufReadPost' },
    keys = {
      { '<leader>gh', '<CMD>lua MiniDiff.toggle_overlay()<CR>', desc = '[MINI] Toggle Diff Overlay' }
    },
    opts = {
      view = {
        style = 'number',
        signs = {
          add = '+',
          change = '~',
          delete = '-',
        },
      },
    },
  },
}
