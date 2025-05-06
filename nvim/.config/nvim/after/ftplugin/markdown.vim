setlocal colorcolumn=0
setlocal wrap nornu
setlocal nolist
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
