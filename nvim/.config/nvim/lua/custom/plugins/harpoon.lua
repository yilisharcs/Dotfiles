return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<C-h>',
        function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list(), { border = 'rounded' }) end,
        desc = '[HARPOON] Open Menu'
      },
      { '<leader>e', function() require('harpoon'):list():add() end,     desc = '[HARPOON] Toggle Mark' },
      { '<leader>h', function() require('harpoon'):list():select(1) end, desc = '[HARPOON] Local mark `h' },
      { '<leader>j', function() require('harpoon'):list():select(2) end, desc = '[HARPOON] Local mark `j' },
      { '<leader>k', function() require('harpoon'):list():select(3) end, desc = '[HARPOON] Local mark `k' },
      { '<leader>l', function() require('harpoon'):list():select(4) end, desc = '[HARPOON] Local mark `l' },
    },
    config = function()
      require('harpoon'):setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = false,
        }
      })

      vim.keymap.set('n', '<C-M-p>', function() require('harpoon'):list():prev() end, { desc = '[HARPOON] Prev mark' })
      vim.keymap.set('n', '<C-M-n>', function() require('harpoon'):list():next() end, { desc = '[HARPOON] Next mark' })

      vim.cmd([[
        augroup harpoon_ctrlnp
          au!
          au Filetype harpoon nnoremap <buffer> <C-n> j
          au Filetype harpoon nnoremap <buffer> <C-p> k
          au Filetype harpoon vnoremap <buffer> q <CMD>bd!<CR>
        augroup END

        " Source ftplugin/$1.lua to override Issue #626
        augroup Harpoon_Optlocal
          au!
          au BufEnter * silent! exec 'source ~/.config/nvim/after/ftplugin/'..&ft..'.vim'
        augroup END
      ]])
    end
  }
}
