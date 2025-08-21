augroup Auto_Cmds
  au!
  " Highlight copied text
  au TextYankPost * lua vim.hl.on_yank({ higroup = "Visual", timeout = 500 })

  " Reads external file changes
  au CursorHold * if &buftype!='nofile' | checktime | endif

  " Open file under cursor on the terminal in a tab
  au TermOpen,TermEnter * nnoremap <buffer> gf <C-w>gF

  " Enter terminal on insert mode
  au TermOpen,TermEnter,WinEnter term://* startinsert

  " Newline doesn't insert comment from comment
  au FileType * set formatoptions-=o | set formatoptions+=r

  " <cfile> only registers apostrophes in markdown files
  au FileType * if &filetype=='markdown' | set isfname+=' | else | set isfname-=' | endif

  " Set listchars like indent-blankline
  au FileType,BufEnter,OptionSet * if &ft != 'snacks_notif'
        \| let &l:listchars=&listchars..',leadmultispace:│'..repeat(' ', &shiftwidth -1)
        \| endif

  " Set registers b-z on launch and exit
  au VimEnter * for i in range(98,102) | silent! call setreg(nr2char(i), []) | endfor
        \| for i in range(104,122) | silent! call setreg(nr2char(i), []) | endfor
        \| let @c='wvg~'
        \| let @m='JjJ^r>}j'
  au VimLeavePre * for i in range(98,102) | silent! call setreg(nr2char(i), [' ']) | endfor
        \| for i in range(104,122) | silent! call setreg(nr2char(i), [' ']) | endfor

  " Automatically open the quickfix window
  au QuickFixCmdPost [^l]* nested cwindow

  " Clear control character from LLM output
  au BufWritePre * let s:c=nvim_win_get_cursor(0)
        \| silent! keeppatterns %s/\\+$//e | call nvim_win_set_cursor(0, s:c)

  " Close terminal buffers as if {cmd} wasn't supplied to :term
  au TermClose *:btop*,*:nu*,*/bin/bash*
        \| silent! execute 'bdelete! '.expand('<abuf>')
augroup END
