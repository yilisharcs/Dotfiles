return {
  {
    'williamboman/mason.nvim',
    ft = {
      'lua',
      'rust',
    },
    keys = {
      { '<leader>qm', vim.cmd.Mason, desc = '[MASON] Open Menu' }
    },
    opts = {
      ui = { border = 'rounded' }
    },
    init = function()
      vim.lsp.enable({
        'luals',
        'rust-analyzer',
      })
    end
  }
}
