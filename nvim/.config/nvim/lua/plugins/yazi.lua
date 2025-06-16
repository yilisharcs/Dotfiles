return {
  "mikavilpas/yazi.nvim",
  lazy = false,
  -- dev = true,
  dependencies = {
    "folke/snacks.nvim",
    "ibhagwan/fzf-lua",
  },
  keys = {
    { "-",         "<CMD>Yazi<CR>",        desc = "Open yazi at the current file" },
    { "<leader>-", "<CMD>Yazi cwd<CR>",    desc = "Open yazi in the working directory" },
    { "<leader>_", "<CMD>Yazi toggle<CR>", desc = "Resume the last yazi session", },
  },
  opts = {
    open_for_directories = true,
    open_multiple_tabs = true,
    log_level = vim.log.levels.WARN,
    floating_window_scaling_factor = {
      -- height = 0.96,
      height = 0.92,
      width = 0.99,
    },
    keymaps = {
      -- https://github.com/mikavilpas/yazi.nvim/issues/739
      open_file_in_vertical_split = false,
      open_file_in_horizontal_split = false,
      cycle_open_buffers = false,
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
