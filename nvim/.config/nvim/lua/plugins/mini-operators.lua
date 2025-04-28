return {
  'echasnovski/mini.operators', -- see `:h MiniOperators.config`.
  version = false,
  keys = {
    { 'g-' },
    { 'cx' },
    { 'gm' },
    { 'cs' },
  },
  opts = {
    evaluate = {
      prefix = 'g-',
      func = nil,
    },
    exchange = {
      prefix = 'cx',
      reindent_linewise = true,
    },
    multiply = {
      prefix = 'gm',
      func = nil,
    },
    replace = {
      prefix = 'cs',
      reindent_linewise = true,
    }
  }
}
