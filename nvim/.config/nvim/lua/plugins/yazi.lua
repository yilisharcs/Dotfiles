return {
  'mikavilpas/yazi.nvim',
  lazy = false,
  dependencies = { 'ibhagwan/fzf-lua' },
  keys = {
    { '-',         '<CMD>Yazi<CR>',        desc = 'Open yazi at the current file' },
    { '<leader>-', '<CMD>Yazi cwd<CR>',    desc = "Open yazi in the working directory" },
    { '<leader>_', '<CMD>Yazi toggle<CR>', desc = 'Resume the last yazi session', },
  },
  opts = {
    open_for_directories = true,
    open_multiple_tabs = true,
    log_level = vim.log.levels.WARN,
    floating_window_scaling_factor = 1.0,
    keymaps = {
      show_help = '<F1>',
      replace_in_directory = false,
    },
    integrations = {
      grep_in_directory = "fzf-lua",
      grep_in_selected_files = "fzf-lua",
    },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
}
