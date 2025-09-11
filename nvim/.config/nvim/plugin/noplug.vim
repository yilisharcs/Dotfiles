function! NoPlugLua()
  bd
  silent grep "return \{" ~/Dotfiles
  Cfilter lua/plugins
  cdo s/$/\renabled = false,
  write
endfunction

nnoremap <leader><F1> <CMD>call NoPlugLua()<CR>
