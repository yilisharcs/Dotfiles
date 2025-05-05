setlocal colorcolumn=120
setlocal iskeyword+=-
let &l:commentstring='" %s'

" Source config
nnoremap <leader><leader>x <CMD>write \| source %<CR>
nnoremap <leader><leader>c :<C-r><C-l><CR>
xnoremap <leader><leader>c "zy:<C-r>z<CR><ESC>
