return {
  {
    'yilisharcs/lf.nvim',
    dependencies = { { 'akinsho/toggleterm.nvim', version = '*', config = true } },
    branch = 'emacs-keybindings',
    cmd = { 'Lf' },
    keys = {
      { '-', '<CMD>Lf<CR>' }
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.g.lf_netrw = 1
    end,
    opts = {
      direction = 'vertical',
      default_file_manager = true,
      disable_netrw_warning = true,
    },
  },
}
