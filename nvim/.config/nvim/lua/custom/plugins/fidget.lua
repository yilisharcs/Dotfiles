return {
  'j-hui/fidget.nvim',
  event = 'LspAttach',
  opts = {
    progress = {
      display = {
        done_icon = '✔ ',
        progress_icon = { pattern = 'moon' },
      },
    },
    notification = {
      window = {
        winblend = vim.g.neovide and 100 or 0,
      },
    }
  }
}
