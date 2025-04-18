if exists("g:neovide")
  let g:terminal_color_0 = '#282828'
  let g:terminal_color_1 = '#EE5396'
  let g:terminal_color_2 = '#25BE6A'
  let g:terminal_color_3 = '#F9E2AF'
  let g:terminal_color_4 = '#78A9FF'
  let g:terminal_color_5 = '#BE95FF'
  let g:terminal_color_6 = '#33B1FF'
  let g:terminal_color_7 = '#DFDFE0'
  let g:terminal_color_8 = '#484848'
  let g:terminal_color_9 = '#F16DA6'
  let g:terminal_color_10 = '#46C880'
  let g:terminal_color_11 = '#FAFECB'
  let g:terminal_color_12 = '#8CB6FF'
  let g:terminal_color_13 = '#C8A5FF'
  let g:terminal_color_14 = '#52BDFF'
  let g:terminal_color_15 = '#E4E4E5'

  let g:neovide_padding_top = 0
  let g:neovide_padding_left = 2
  let g:neovide_hide_mouse_when_typing = v:true
  let g:neovide_confirm_quit = v:true
  let g:neovide_cursor_smooth_blink = v:true
  let g:neovide_cursor_animate_in_insert_mode = v:true
  let g:neovide_cursor_animate_command_line = v:true
  let g:neovide_detach_on_quit = 'always_detach'

  let &guifont='JetBrainsMono Nerd Font Mono:h13'
  let g:neovide_scale_factor = 1.0
  lua vim.keymap.set({ 'n', 't' }, '<C-->', '<CMD>let g:neovide_scale_factor-=0.1<CR>')
  lua vim.keymap.set({ 'n', 't' }, '<C-=>', '<CMD>let g:neovide_scale_factor+=0.1<CR>')
  lua vim.keymap.set({ 'n', 't' }, '<C-0>', '<CMD>let g:neovide_scale_factor=1.0<CR>')

  let g:neovide_fullscreen = v:false
  set linespace=2
  function! Neovide_F11()
    if g:neovide_fullscreen == v:false
      let g:neovide_fullscreen = v:true
      set linespace=1
    else
      let g:neovide_fullscreen = v:false
      set linespace=2
    endif
  endfunction
  lua vim.keymap.set({ '', 'x', '!', 't' }, '<F11>', '<CMD>call Neovide_F11()<CR>')

  noremap! <C-S-V> <C-r>+
  tnoremap <C-S-V> <C-\><C-n>pi

  " Neovide doesn't register C-4 as C-\
  tnoremap <expr> <C-4><C-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
  tnoremap <C-4><C-n> <C-\><C-n>

  " Tmux-like workflow
  nnoremap <C-SPACE><C-^> <CMD>wincmd g<TAB><CR>
  " C-^ registers as <TAB> for reasons unknown
  tnoremap <C-SPACE><C-6> <CMD>wincmd g<TAB><CR>
  nnoremap <C-SPACE><LEFT> <CMD>-tabmove<CR>
  nnoremap <C-SPACE><RIGHT> <CMD>+tabmove<CR>
  tnoremap <C-SPACE>t <CMD>tab split<CR>
  tnoremap <C-SPACE>[ <CMD>silent! !tmux copy-mode<TAB><CR>

  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>-', '<CMD>split | term nu<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>=', '<CMD>vsplit | term nu<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>c', '<CMD>tabnew | term nu<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>x', '<CMD>tabclose<CR>')

  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>1', '<CMD>1tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>2', '<CMD>2tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>3', '<CMD>3tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>4', '<CMD>4tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>5', '<CMD>5tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>6', '<CMD>6tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>7', '<CMD>7tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>8', '<CMD>8tabnext<CR>')
  lua vim.keymap.set({ '', '!', 't' }, '<C-SPACE>9', '<CMD>9tabnext<CR>')

  augroup RustyShell
    au!
    " Set default cwd if opened with no files as arguments
    au UIEnter * if argc(-1) == 0 | cd ~/.dotfiles | endif
    " Close nu buffers as if {cmd} wasn't supplied to :term
    au TermClose *:nu* silent! execute 'bdelete! '.expand('<abuf>')
  augroup END
endif
