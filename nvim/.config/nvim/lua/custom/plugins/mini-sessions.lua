return {
  {
    'echasnovski/mini.sessions', -- see `:h MiniSessions.config`.
    version = false,
    opts = {
      force = {
        read = false,
        write = true,
        delete = true
      },
    },
    config = function(_, opts)
      require('mini.sessions').setup(opts)

      vim.keymap.set('n', '<leader>cn', function() require('mini.sessions').write(vim.fn.expand('%:t:r'), {}) end,
        { desc = '[MINI] Session New' })
      vim.keymap.set('n', '<leader>cl', function() require('mini.sessions').select() end,
        { desc = '[MINI] Session List' })
      vim.keymap.set('n', '<leader>cg', function() require('mini.sessions').delete() end,
        { desc = '[MINI] Session Delete' })
    end
  },
}
