return {
  {
    'williamboman/mason.nvim',
    build = ':MasonInstall ' ..
        'lua-language-server',
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
