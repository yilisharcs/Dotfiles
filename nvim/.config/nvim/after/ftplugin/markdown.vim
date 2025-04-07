setlocal colorcolumn=0
setlocal wrap
setlocal linebreak
setlocal nolist
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal noexpandtab
setlocal suffixesadd+=.md,.lemon
setlocal iskeyword+=-,'
setlocal isfname+='
let &l:commentstring='<!-- %s -->'

inoremap <buffer> ... …

" mini doesn't surround a line with newlines
lua << EOF
  vim.b.minisurround_config = {
    respect_selection_type = false,
  }
EOF
