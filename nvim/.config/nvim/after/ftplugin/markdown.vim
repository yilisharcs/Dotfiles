setlocal colorcolumn=0
setlocal wrap
setlocal linebreak
setlocal nolist
setlocal noexpandtab
setlocal suffixesadd+=.md,.lemon
setlocal iskeyword+=-,'
setlocal isfname+='
let &l:commentstring='<!-- %s -->'

augroup Dialogue_Local_Tag
    au!
    au InsertEnter *.md if &l:spelllang == 'en_us'
                \| inoremap <buffer> <C-k> <C-o>o<CR>""<Left>
                \| elseif &l:spelllang == 'pt_br'
                \| inoremap <buffer> <C-k> <C-o>o<CR>—<Space>
                \| endif
augroup END

inoremap <buffer> ... …

function! Sort_Music_List()
    4,$Tableize/|
    4,$s/| \(.*\)|$/\1
    language collate pt_BR.UTF-8
    4,$sort l
    write
endfunction
nnoremap <buffer> <leader>= :call Sort_Music_List()<CR>

" mini doesn't surround a line with newlines
lua << EOF
  vim.b.minisurround_config = {
    respect_selection_type = false,
  }
EOF
