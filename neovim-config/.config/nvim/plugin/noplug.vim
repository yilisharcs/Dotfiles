function! NoPlugLua()
        " FIXME: use vim.pack?
        packadd cfilter
        silent grep "return \{" ~/Dotfiles
        Cfilter lua/plugins
        cdo s/$/\renabled = false,
endfunction

nnoremap <leader><F1> <CMD>call NoPlugLua()<CR><CMD>wall<CR>
