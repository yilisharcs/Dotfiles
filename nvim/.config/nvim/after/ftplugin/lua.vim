setlocal colorcolumn=80
setlocal expandtab
setlocal keywordprg=:help

" Source config
nnoremap <leader><leader>x <CMD>write \| source %<CR>
nnoremap <leader><leader>c :lua <C-r><C-l><CR>
