augroup au_cmds
    au!
    " Highlight copied text
    au TextYankPost * lua vim.highlight.on_yank({ timeout = 500 })
    " Clear trailing postspaces
    au BufWritePre * let s:c=nvim_win_get_cursor(0) | keeppatterns %s/\(\s\|\)\+$//e | call nvim_win_set_cursor(0, s:c)
    " Reads external file changes
    au CursorHold * if &buftype!='nofile' | checktime | endif
    " Terminal options
    au TermOpen,TermEnter * setlocal signcolumn=no nonu nornu | startinsert
    " Newline doesn't insert comment from comment
    au FileType * set formatoptions-=o
    " Prevent conflicts from autoread
    au FocusLost * silent! noautocmd update
    " Set listchars like indent-blankline
    au FileType,BufEnter,OptionSet * let &l:listchars=&listchars..',leadmultispace:│'..repeat(' ', &shiftwidth -1)
augroup END
