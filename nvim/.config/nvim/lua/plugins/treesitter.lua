return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost [^:]*', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'comment',
          'markdown_inline',
          'nu',
          'rust',
        },
        sync_install = false,
        auto_install = false,
        ignore_install = {
          'make',
          'tmux',
        },
        highlight = { enable = true },
        indent = { enable = true },
        additional_vim_regex_highlighting = false,
      })

      vim.keymap.set('n', '<M-u>', '<CMD>TSBufToggle highlight<CR>', { desc = '[TS] Toggle Highlight' })
      vim.keymap.set('n', '<leader><F9>', '<CMD>InspectTree<CR>', { desc = '[TS] Inspect Tree' })

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
