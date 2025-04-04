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

" https://gist.github.com/kipawaa/a2e5a6a0c33329ec3b4e949a8edf9d69

function! s:auto_list()
    let l:prev_line = getline(line(".") - 1)
    let l:whitespace = matchstr(l:prev_line, '\v^\s*')
    if l:prev_line =~ '\v^\s*\d+\.\s\S+.*$'
        let l:whitespace_and_list_index = matchstr(l:prev_line, '\v^\s*\d*')
        let l:list_index = matchstr(l:whitespace_and_list_index, '\v\d+')
        call setline(".", l:whitespace . (l:list_index + 1) . ". ")
    elseif l:prev_line =~ '\v^\s*\d+\.\s*$'
        call setline(line(".") - 1, "")
    elseif l:prev_line =~ '\v^\s*\-\s.+$'
        call setline(".", l:whitespace . "- ")
    elseif l:prev_line =~ '\v^\s*\-\s*$'
        call setline(line(".") - 1, "")
    endif
endfunction

inoremap <buffer> <CR> <CR><Esc>:call <SID>auto_list()<CR>A
