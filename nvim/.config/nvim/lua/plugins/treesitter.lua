return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'RRethy/nvim-treesitter-endwise',
    'HiPhish/rainbow-delimiters.nvim',
    {
      'nvim-treesitter/nvim-treesitter-context',
      opts = {
        min_window_height = 20,
        separator = '⥰',
        on_attach = function(bufnr)
          return vim.bo[bufnr].filetype ~= 'markdown'
        end
      }
    },
  },
  build = ':TSUpdate',
  cond = not vim.g.shell_editor == true,
  event = { 'BufReadPost [^:]*', 'BufNewFile' },
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'comment',
        'nix',
        'nu',
        'rust',
      },
      sync_install = false,
      auto_install = true,
      ignore_install = {
        'make',
        'tmux',
      },
      highlight = { enable = true },
      indent = { enable = true },
      additional_vim_regex_highlighting = false,
    })

    vim.keymap.set('n', '<M-u>', '<CMD>TSBufToggle highlight | TSContextToggle<CR>', { desc = '[TS] Toggle highlights' })
    vim.keymap.set('n', '<leader><F9>', '<CMD>InspectTree<CR>', { desc = '[TS] Inspect tree' })

    vim.cmd([[
      " Required: treesitter resets filetype syntax opts
      augroup Markdown_Syn
        au!
        au BufEnter *.md set syntax=ON
      augroup END
    ]])
  end
}
