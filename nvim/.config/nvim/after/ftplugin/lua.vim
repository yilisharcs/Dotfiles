setlocal colorcolumn=80
setlocal expandtab
setlocal keywordprg=:help

" Source config
nnoremap <leader><leader>x <CMD>write \| source %<CR>
nnoremap <leader><leader>c <CMD>.lua<CR>
xnoremap <leader><leader>c <CMD>'<,'>.lua<CR><ESC>
