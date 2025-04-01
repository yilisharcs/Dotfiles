function! List_Gmarks()
    marks ABCDEFGIMNOPQRSTUVWXYZ
    marks HJKL
    echo('`')
    try
        let s:mark = toupper(nr2char(getchar()))
    catch /^Vim:Interrupt$/
    endtry
    redraw
    silent! execute 'normal! `'..s:mark
endfunction

nnoremap <C-h> <CMD>call List_Gmarks()<CR>
