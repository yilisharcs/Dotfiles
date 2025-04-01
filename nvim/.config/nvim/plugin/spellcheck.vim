set spelllang=en_us
set spellfile=$XDG_CONFIG_HOME/spell/en.utf-8.add,$XDG_CONFIG_HOME/spell/pt.utf-8.add

nnoremap <C-s> <CMD>set spell!<CR>
inoremap <C-s> <ESC>gEB1z=eea
nnoremap z2g zg2zg

function! ToggleLang() abort
    if &l:spelllang == "en_us"
        setlocal spelllang=pt_br
        setlocal spellfile=$XDG_CONFIG_HOME/spell/pt.utf-8.add,$XDG_CONFIG_HOME/spell/en.utf-8.add
        echo &spelllang
    else
        setlocal spelllang=en_us
        setlocal spellfile=$XDG_CONFIG_HOME/spell/en.utf-8.add,$XDG_CONFIG_HOME/spell/pt.utf-8.add
        echo &spelllang
    endif
endfunction

nnoremap <M-y> <CMD>call ToggleLang()<CR>
