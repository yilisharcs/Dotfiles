setlocal colorcolumn=120
let &l:commentstring='// %s'
let b:editorconfig = v:false

cnoreabbrev <buffer> <expr> cargo (getcmdtype() ==# ':' && getcmdline() =~# '^cargo') ? 'Cargo' : 'cargo'

augroup Rust_C_Plug
  au!
  " Jump to file error; requires vim-sneak
  au TermOpen *:cargo* lua vim.keymap.set('n', '-', '6s> ', { remap = true, buffer = true })
augroup END
