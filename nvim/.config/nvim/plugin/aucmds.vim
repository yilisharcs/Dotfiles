augroup Auto_Cmds
    au!
    " Highlight copied text
    au TextYankPost * lua vim.highlight.on_yank({ timeout = 500 })
    " Clear trailing postspaces
    au BufWritePre * let s:c=nvim_win_get_cursor(0) | silent! keeppatterns %s/\(\s\|\)\+$//e | call nvim_win_set_cursor(0, s:c)
    " Reads external file changes
    au CursorHold * if &buftype!='nofile' | checktime | endif
    " Terminal options
    au TermOpen,TermEnter * startinsert
    " Newline doesn't insert comment from comment
    au FileType * set formatoptions-=o
    " Prevent conflicts from autoread
    au FocusLost * silent! noautocmd update
    " Set listchars like indent-blankline
    au FileType,BufEnter,OptionSet * let &l:listchars=&listchars..',leadmultispace:│'..repeat(' ', &shiftwidth -1)
    " Set registers b-z on launch and exit
    au VimEnter * for i in range(98,102) | silent! call setreg(nr2char(i), []) | endfor
                \| for i in range(104,122) | silent! call setreg(nr2char(i), []) | endfor
                \| let @c='wvg~'
    au VimLeavePre * for i in range(98,102) | silent! call setreg(nr2char(i), [' ']) | endfor
                \| for i in range(104,122) | silent! call setreg(nr2char(i), [' ']) | endfor
    " Automatically open the quickfix window
    au QuickFixCmdPost [^l]* nested cwindow
    " Turn off folds for dotfiles only
    au BufEnter */.config/** setlocal nofoldenable
augroup END
