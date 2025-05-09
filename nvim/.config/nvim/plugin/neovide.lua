if vim.g.neovide then
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_left = 2
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.o.winblend = 1

  vim.go.guifont = 'JetBrainsMono_Nerd_Font,Noto_Color_Emoji:h13'
  -- vim.go.guifont = 'JetBrainsMonoNL_Nerd_Font,Noto_Color_Emoji:h13'
  vim.g.neovide_scale_factor = 1.0
  vim.keymap.set({ 'n', 't' }, '<C-->', '<CMD>let g:neovide_scale_factor-=0.1<CR>')
  vim.keymap.set({ 'n', 't' }, '<C-=>', '<CMD>let g:neovide_scale_factor+=0.1<CR>')
  vim.keymap.set({ 'n', 't' }, '<C-0>', '<CMD>let g:neovide_scale_factor=1.0<CR>')

  vim.g.neovide_fullscreen = true
  vim.go.linespace = 1
  -- vim.g.neovide_fullscreen = false
  -- vim.go.linespace = 2
  function Neovide_F11()
    if vim.g.neovide_fullscreen == false then
      vim.g.neovide_fullscreen = true
      vim.go.linespace = 1
    else
      vim.g.neovide_fullscreen = false
      vim.go.linespace = 2
    end
    if package.loaded['vim._extui'] then
      vim.cmd('sleep 500m')
      vim.cmd('new | close')
    end
  end

  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<F11>', '<CMD>lua Neovide_F11()<CR>')

  -- Neovide doesn't register C-4 as C-\
  vim.keymap.set('t', '<C-4><C-n>', [[<C-\><C-n>]])

  vim.cmd([[
    augroup Neovide_Gen_Opts
      au!
      " Set default cwd if opened with no files as arguments
      au UIEnter * if argc(-1) == 0 | cd ~/.dotfiles | endif
      " Close terminal buffers as if {cmd} wasn't supplied to :term
      au TermClose *:btop*,*:nu*,*/bin/bash*
            \| silent! execute 'bdelete! '.expand('<abuf>')
    augroup END
  ]])
end
