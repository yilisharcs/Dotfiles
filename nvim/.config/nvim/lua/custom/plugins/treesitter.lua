return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      { 'HiPhish/rainbow-delimiters.nvim',         branch = 'fix-highlighting' },
      { 'nvim-treesitter/nvim-treesitter-context', opts = { min_window_height = 20 } },
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'asm',
          'awk',
          'c',
          'cmake',
          'comment',
          'diff',
          'ini',
          'html',
          'javascript',
          'lua',
          'markdown',
          'markdown_inline',
          'ninja',
          'objdump',
          'powershell',
          'python',
          'query',
          'regex',
          'rust',
          'scheme',
          'sql',
          'ssh_config',
          'toml',
          'typescript',
          'vim',
          'vimdoc',
          'xml',
          'yaml',
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {
          'make',
          'tmux',
        },
        highlight = {
          enable = true,
          disable = function()
            local deforest = {
              '.zsh_history',
            }
            if vim.tbl_contains(deforest, vim.fn.expand('%:t')) then return true end
          end
        },
        indent = { enable = true },
        additional_vim_regex_highlighting = false,
      })

      vim.keymap.set('n', '<M-u>', function() vim.cmd.TSBufToggle('highlight') end, { desc = '[TS] Toggle Highlight' })
      vim.keymap.set('n', '<F9>', '<CMD>Inspect<CR>', { desc = '[TS] Inspect Object' })
      vim.keymap.set('n', '<leader><F9>', vim.cmd.InspectTree, { desc = '[TS] Inspect Tree' })

      vim.cmd([[
        augroup TS_Context_Bar
          au!
          au BufEnter,FileType *.html,*.md,*.lemon silent! TSContextDisable
        augroup END

        " Required: treesitter resets filetype syntax opts
        augroup syn_opts
          au!
          au BufEnter *.md set syntax=ON
        augroup END
      ]])
    end
  }
}
