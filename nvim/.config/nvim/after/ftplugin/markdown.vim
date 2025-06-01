setlocal colorcolumn=0
setlocal wrap nornu
setlocal nolist
setlocal noexpandtab
setlocal suffixesadd+=.md,.lemon
setlocal iskeyword+=-,'
let &l:commentstring='<!-- %s -->'

" This helps distinguish comments within fenced code blocks
setlocal winhighlight+=@comment:FilterMenuLineNr,@comment.html:Comment

" Make time heading for zk
nnoremap <silent> <F2> G{{O<CR>### <C-r>=strftime('%H:%M')<CR><CR>

" mini doesn't surround a line with newlines
lua << EOF
  vim.b.minisurround_config = {
    respect_selection_type = false,
  }
EOF
