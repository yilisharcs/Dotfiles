" https://github.com/justinmk/config/blob/master/.config/nvim/plugin/winning.lua#L102-L122

func! s:focusable_wins() abort
    return filter(nvim_tabpage_list_wins(0), {k,v-> !!nvim_win_get_config(v).focusable})
endf
augroup config_curwin_border
    autocmd!
    highlight CursorLineNC gui=underdashed guisp=NvimLightGrey4 guibg=NONE
    highlight WinBorder guibg=#cba6f7

    " Dim non-current cursorline.
    autocmd VimEnter,WinEnter,TabEnter,BufEnter * setlocal winhighlight-=CursorLine:CursorLineNC

    " Highlight curwin WinSeparator/FoldColumn for "border" effect.
    let s:winborder_hl = 'WinSeparator:WinBorder,FoldColumn:WinBorder'
    autocmd WinLeave * exe 'setlocal winhighlight+=CursorLine:CursorLineNC winhighlight-='..s:winborder_hl
    autocmd WinEnter * exe 'setlocal winhighlight+='..s:winborder_hl
    " Disable effect if there is only 1 window. BufEnter,TabEnter prevent misfires on BufDelete
    autocmd BufEnter,TabEnter,WinResized * if 1 == len(s:focusable_wins())
                \| exe 'setlocal winhighlight-='..s:winborder_hl | endif

    " Pattern/event doesn't work with lf/toggleterm unless made as a standalone autocmd for some reason.
    autocmd TermLeave *lf*toggleterm* exe 'setlocal winhighlight+=CursorLine:CursorLineNC winhighlight-='..s:winborder_hl
augroup END
