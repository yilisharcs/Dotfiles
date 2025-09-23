hi! link mdTextInQuotes String
hi userHandle guifg=#87ffff

syn match mdTextInQuotes /\v(["])%(\1@![^\\]|\\.)*\1/
syn match userHandle /\s@\w*/
