return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    cmd = { 'Neogit' },
    keys = {
      { '<leader>qg', '<CMD>Neogit<CR>', desc = '[NEOGIT] Status' },
    },
    config = function(_, opts)
      require('neogit').setup(opts)

      vim.cmd([[
        augroup neogit_ctrlnp
          au!
          au Filetype NeogitStatus nnoremap <buffer> <C-p> k
          au Filetype NeogitStatus nnoremap <buffer> <C-n> j
          au Filetype NeogitCommitMessage setlocal iskeyword+=-,'
          au Filetype NeogitCommitMessage nnoremap <buffer> <C-s> <ESC>gEB1z=eea
        augroup END
      ]])

      local actions = require('diffview.actions')

      require('diffview').setup({
        view = { default = { layout = 'diff2_vertical' } },
        file_panel = {
          win_config = {
            position = 'right',
            width = math.floor(vim.o.columns * 0.33 + 0.5),
          },
        },
        keymaps = {
          view = {
            { 'n', '<C-j>', actions.select_next_entry, { desc = 'Open the diff for the next file' } },
            { 'n', '<C-k>', actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
          },
          file_panel = {
            { 'n', '<C-j>', actions.select_next_entry,  { desc = 'Open the diff for the next file' } },
            { 'n', '<C-k>', actions.select_prev_entry,  { desc = 'Open the diff for the previous file' } },
            { 'n', '<c-p>', actions.scroll_view(-0.25), { desc = 'Scroll the view up' } },
            { 'n', '<c-n>', actions.scroll_view(0.25),  { desc = 'Scroll the view down' } },
          },
          file_history_panel = {
            { 'n', '<C-j>', actions.select_next_entry,  { desc = 'Open the diff for the next file' } },
            { 'n', '<C-k>', actions.select_prev_entry,  { desc = 'Open the diff for the previous file' } },
            { 'n', '<c-p>', actions.scroll_view(-0.25), { desc = 'Scroll the view up' } },
            { 'n', '<c-n>', actions.scroll_view(0.25),  { desc = 'Scroll the view down' } },
          },
        },
      })
    end,
  }
}
