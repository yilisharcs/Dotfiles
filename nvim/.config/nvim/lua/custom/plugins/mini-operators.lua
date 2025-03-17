return {
  {
    'echasnovski/mini.operators', -- see `:h MiniOperators.config`.
    version = false,
    keys = {
      { 'g=' },
      { 'cx' },
      { 'gm' },
      { 'cs' },
      { 'gs' },
    },
    opts = {
      evaluate = {
        prefix = 'g=', -- Evaluate text and replace with output
        func = nil,
      },
      exchange = {
        prefix = 'cx', -- Exchange text regions
        reindent_linewise = true,
      },
      multiply = {
        prefix = 'gm', -- Duplicate text
        func = nil,
      },
      replace = {
        prefix = 'cs', -- Substitute text with content from register
        reindent_linewise = true,
      },
      sort = {
        prefix = 'gs',
        func = nil,
      },
    },
    config = function(_, opts)
      require('mini.operators').setup(opts)

      vim.keymap.set('n', 'gsap', 'gsip', { remap = true })
      vim.keymap.set('n', 'csgn', '*``csgn', { remap = true, desc = '[MINI] Substitute next <cword>' })
      vim.keymap.set('n', 'csgN', '*``csgN', { remap = true, desc = '[MINI] Substitute prev <cword>' })

      vim.keymap.set('n', 'X', "<Cmd>lua MiniOperators.exchange('visual')<CR>", { desc = '[MINI] Visual exchange' })
    end
  },
}
