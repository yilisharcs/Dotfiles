return {
  {
    'NeogitOrg/neogit',
    dependencies = 'nvim-lua/plenary.nvim',
    event = 'CmdlineEnter',
    init = function()
      vim.cmd([[
        cnoreabbrev <expr> git (getcmdtype() ==# ':' && getcmdline() =~# '^git') ? 'Neogit' : 'git'

        augroup Neo_Legit
          au!
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
    }
  }
}
