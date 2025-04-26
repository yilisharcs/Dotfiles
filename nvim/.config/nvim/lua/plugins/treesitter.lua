return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'RRethy/nvim-treesitter-endwise',
      {
        'HiPhish/rainbow-delimiters.nvim',
        init = function()
          vim.api.nvim_create_autocmd('ColorScheme', {
            group    = vim.api.nvim_create_augroup('Rainbow_Delim_Hl', { clear = true }),
            callback = function()
              vim.api.nvim_set_hl(0, 'RainbowDelimiterRed', { fg = '#ff5f5f' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow', { fg = '#ffd787' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue', { fg = '#458588' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange', { fg = '#d65d0e' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen', { fg = '#46c880' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet', { fg = '#c8a5ff' })
              vim.api.nvim_set_hl(0, 'RainbowDelimiterCyan', { fg = '#52bdff' })
            end
          })
        end
      },
    },
    build = ':TSUpdate',
    event = { 'BufReadPost [^:]*', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'comment',
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

      vim.keymap.set('n', '<M-u>', '<CMD>TSBufToggle highlight<CR>', { desc = '[TS] Toggle highlights' })
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
}
