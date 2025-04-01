return {
  {
    'justinmk/vim-sneak',
    dependencies = { 'tpope/vim-repeat' },
    init = function()
      vim.g['sneak#use_ic_scs'] = 1
      vim.cmd([[
        augroup Sneak_Insert_HL
          au!
          au InsertEnter * hi Sneak NONE
          au InsertLeave * hi Sneak guifg=#0c0c0c guibg=#be95ff
        augroup END
      ]])
    end,
    keys = {
      { 's', '<Plug>Sneak_s', mode = { 'n', 'x' } },
      { 'S', '<Plug>Sneak_S', mode = { 'n', 'x' } },
      { 'z', '<Plug>Sneak_s', mode = 'o' },
      { 'Z', '<Plug>Sneak_S', mode = 'o' },
      { 'f', '<Plug>Sneak_f', mode = { 'n', 'x', 'o' } },
      { 'F', '<Plug>Sneak_F', mode = { 'n', 'x', 'o' } },
      { 't', '<Plug>Sneak_t', mode = { 'n', 'x', 'o' } },
      { 'T', '<Plug>Sneak_T', mode = { 'n', 'x', 'o' } },
    },
  }
}
