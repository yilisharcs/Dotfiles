function! ToggleLang()
  " Vim stops detecting .spl files if spell isn't set beforehand
  set spell

  if &l:spelllang =~ "en"
    setlocal spelllang=pt_br
    setlocal spellfile=$XDG_CONFIG_HOME/nvim/spell/pt.utf-8.add,$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
    echo &spelllang
  else
    setlocal spelllang=en_us
    setlocal spellfile=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add,$XDG_CONFIG_HOME/nvim/spell/pt.utf-8.add
    echo &spelllang
  endif
endfunction

nnoremap <F4> <CMD>call ToggleLang()<CR>
nnoremap <C-s> <CMD>set spell!<CR>
inoremap <C-s> <ESC>gEB1z=eea
nnoremap z2g zg2zg
