return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    event = 'CmdlineEnter',
    keys = {
      { '<leader>gq', '<CMD>Neogit<CR>' },
      { '<leader>gl', '<CMD>DiffviewFileHistory %<CR>' },
      { '<leader>gL', '<CMD>DiffviewFileHistory<CR>' },
    },
    init = function()
      vim.cmd([[
        cnoreabbrev <expr> git (getcmdtype() ==# ':' && getcmdline() =~# '^git') ? 'Neogit' : 'git'

        augroup Neogit_Ctrl_Map
          au!
          au Filetype NeogitStatus nnoremap <buffer> <C-p> k
          au Filetype NeogitStatus nnoremap <buffer> <C-n> j
          au Filetype NeogitCommitMessage setlocal iskeyword+=-,'
          au Filetype NeogitCommitMessage nnoremap <buffer> <C-s> <ESC>gEB1z=eea
        augroup END
      ]])

      vim.api.nvim_create_autocmd('ColorScheme', {
        group    = vim.api.nvim_create_augroup('Neogit_Buffer_Hl', { clear = true }),
        callback = function()
          vim.api.nvim_set_hl(0, 'NeogitStagedchanges', { fg = '#a6e3a1', bold = true })
          vim.api.nvim_set_hl(0, 'NeogitUnstagedchanges', { fg = '#fab387', bold = true })
          vim.api.nvim_set_hl(0, 'NeogitUntrackedfiles', { fg = '#f38ba8', bold = true })
          vim.api.nvim_set_hl(0, 'NeogitUnmergedchanges', { fg = '#cba6f7', bold = true })
          vim.api.nvim_set_hl(0, 'NeogitGraphPurple', { fg = '#fab387' })
        end
      })
    end,
    opts = {
      graph_style = 'unicode',
      integrations = {
        diffview = true,
      }
    },
    config = function(_, opts)
      require('neogit').setup(opts)

      local actions = require('diffview.actions')

      require('diffview').setup({
        view = {
          default = {
            layout = 'diff2_vertical'
          }
        },
        file_panel = {
          win_config = {
            position = 'right',
            width = math.floor(vim.o.columns * 0.33 + 0.5),
          },
        },
        keymaps = {
          view = {
            { 'n', '<C-n>', actions.select_next_entry, { desc = 'Open the diff for the next file' } },
            { 'n', '<C-p>', actions.select_prev_entry, { desc = 'Open the diff for the previous file' } },
          },
          file_panel = {
            { 'n', '<C-n>', actions.select_next_entry,  { desc = 'Open the diff for the next file' } },
            { 'n', '<C-p>', actions.select_prev_entry,  { desc = 'Open the diff for the previous file' } },
            { 'n', '<c-k>', actions.scroll_view(-0.25), { desc = 'Scroll the view up' } },
            { 'n', '<c-j>', actions.scroll_view(0.25),  { desc = 'Scroll the view down' } },
          },
          file_history_panel = {
            { 'n', '<C-n>', actions.select_next_entry,  { desc = 'Open the diff for the next file' } },
            { 'n', '<C-p>', actions.select_prev_entry,  { desc = 'Open the diff for the previous file' } },
            { 'n', '<c-k>', actions.scroll_view(-0.25), { desc = 'Scroll the view up' } },
            { 'n', '<c-j>', actions.scroll_view(0.25),  { desc = 'Scroll the view down' } },
          },
        },
      })
    end
  }
}
