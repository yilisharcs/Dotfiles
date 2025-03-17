syn match mdTextInQuotes /\v(["])%(\1@![^\\]|\\.)*\1/

hi mdTextInQuotes ctermfg=cyan guifg=#fab387
