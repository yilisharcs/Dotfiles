return {
  'williamboman/mason.nvim',
  build = ':MasonInstall ' ..
    'lua-language-server ' ..
    'vim-language-server',
  ft = {
    'lua',
    'rust',
    'vim',
  },
  keys = {
    { '<leader>qm', '<CMD>Mason<CR>', desc = '[MASON] Menu' }
  },
  opts = {
    ui = {
      border = 'rounded',
      backdrop = 100,
    }
  },
  init = function()
    vim.lsp.enable({
      'luals',
      'rust-analyzer',
      'vimls',
    })
    -- make sure mason can detect fnm
    vim.env.PATH = vim.env.HOME ..
      "/.local/share/fnm/aliases/default/bin:" ..
      vim.env.PATH
  end
}
