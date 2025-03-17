return {
  {
    'yilisharcs/lf.nvim',
    dependencies = { { 'akinsho/toggleterm.nvim', version = '*', config = true } },
    commit = 'a06468f3f65cf4a27863a52d83cf7473039705e7',
    priority = 999,
    cmd = { 'Lf' },
    keys = {
      { '<leader>y', '<CMD>Lf<CR>', desc = 'Open file manager' }
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.lf_netrw = 1
    end,
    opts = {
      border = 'rounded',
      winblend = 0,
      default_file_manager = true,
      disable_netrw_warning = true,
    },
  },
}
