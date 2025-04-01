hi mdTextInQuotes guifg=#fab387

syn match mdTextInQuotes /\v(["])%(\1@![^\\]|\\.)*\1/
