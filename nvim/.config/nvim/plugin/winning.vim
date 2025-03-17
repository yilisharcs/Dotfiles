" https://github.com/justinmk/config/blob/master/.config/nvim/plugin/winning.lua#L102-L122
"
" Highlight current window
"
func! s:focusable_wins() abort
    return filter(nvim_tabpage_list_wins(0), {k,v-> !!nvim_win_get_config(v).focusable})
endf
augroup config_curwin_border
    autocmd!
    highlight CursorLineNC cterm=underdashed gui=underdashed ctermfg=gray guisp=NvimLightGrey4 ctermbg=NONE guibg=NONE
    highlight link WinBorder Statusline

    " Dynamically change winborder colors
    execute 'hi! Winborder guibg=#89b4fa guifg=#1e1e2e'
    autocmd ModeChanged *:n,*:no,*:nov,*:noV,*:no,*:niI,*:nt execute 'hi! Winborder guibg=#89b4fa'
    autocmd ModeChanged *:i,*:ic,*:ix,*:t execute 'hi! Winborder guibg=#a6e3a1'
    autocmd ModeChanged *:c,*:cr,*:cv,*:cvr execute 'hi! Winborder guibg=#fab387' | redraw
    autocmd ModeChanged *:v,*:vs,*:V,*:Vs,*:,*:s execute 'hi! Winborder guibg=#cba6f7'
    autocmd ModeChanged *:R,*:Rc,*:Rx,*:Rv,*:Rvc,*:Rvx execute 'hi! Winborder guibg=#f38ba8'

    " Dim non-current cursorline.
    autocmd VimEnter,WinEnter,TabEnter,BufEnter * setlocal winhighlight-=CursorLine:CursorLineNC

    " Highlight curwin WinSeparator/SignColumn for "border" effect.
    let s:winborder_hl = 'WinSeparator:WinBorder,SignColumn:WinBorder'
    autocmd WinLeave * exe 'setlocal winhighlight+=CursorLine:CursorLineNC winhighlight-='..s:winborder_hl
    autocmd WinEnter * exe 'setlocal winhighlight+='..s:winborder_hl
    " Disable effect if there is only 1 window. BufEnter,TabEnter prevent misfires on BufDelete
    autocmd BufEnter,TabEnter,WinResized * if 1 == len(s:focusable_wins())
                \| exe 'setlocal winhighlight-='..s:winborder_hl | endif

    " Lf integration. Pattern/event doesn't work unless made as a standalone autocmd for some reason.
    autocmd TermLeave *lf*toggleterm* exe 'setlocal winhighlight+=CursorLine:CursorLineNC winhighlight-='..s:winborder_hl
augroup END
