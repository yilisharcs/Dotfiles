setlocal colorcolumn=0
setlocal wrap nornu
setlocal linebreak
setlocal nolist

nnoremap <buffer> ,gnu ggdG:0read $XDG_CONFIG_HOME/nvim/skeletons/license/gpl-3.0.txt \| $d_<CR>gg
