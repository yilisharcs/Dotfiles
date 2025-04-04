hi mdTextInQuotes guifg=#fab387
hi TaskTag guifg=#25be6a

syn match mdTextInQuotes /\v(["])%(\1@![^\\]|\\.)*\1/
syn match TaskTag /\s@\w*/
