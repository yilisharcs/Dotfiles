return {
  {
    'echasnovski/mini.pairs', -- see `:h MiniPairs.config`.
    version = false,
    event = { 'InsertEnter' },
    opts = {
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].', register = { bs = true, cr = true } },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].', register = { bs = true, cr = true } },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].', register = { bs = true, cr = true } },

        -- Doesn't pair after a whitespace char (useful for math)
        ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^ \\].', register = { bs = true } },
        ['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].' },
      }
    },
    config = function(_, opts)
      require('mini.pairs').setup(opts)

      local map_bs = function(lhs, rhs)
        vim.keymap.set('i', lhs, rhs, { expr = true, replace_keycodes = false })
      end

      map_bs('<C-h>', 'v:lua.MiniPairs.bs()')
      map_bs('<C-w>', 'v:lua.MiniPairs.bs("\23")')
      map_bs('<C-u>', 'v:lua.MiniPairs.bs("\21")')

      vim.cmd([[
        augroup pairs_rust
          au!
          au InsertEnter *.rs inoremap <buffer> ' '
        augroup END
      ]])
    end
  },
}
