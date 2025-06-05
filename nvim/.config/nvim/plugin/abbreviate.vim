cabbrev W w
cabbrev Wq wq
cabbrev Wa wa
cabbrev wa1 wa!
cabbrev W1 w!
cabbrev w1 w!
cabbrev wq1 wq!
cabbrev Q q
cabbrev Qa qa
cabbrev Qa1 qa!
cabbrev q1 q!
cabbrev qa1 qa!
cabbrev bd1 bd!

cnoreabbrev <expr> cfilter (getcmdtype() ==# ':' && getcmdline() =~# '^cfilter') ? 'Cfilter' : 'cfilter'
cnoreabbrev <expr> grep (getcmdtype() ==# ':' && getcmdline() =~# '^grep') ? 'silent grep' : 'grep'
cnoreabbrev <expr> hgrep (getcmdtype() ==# ':' && getcmdline() =~# '^hgrep') ? 'helpgrep' : 'hgrep'
cnoreabbrev <expr> man (getcmdtype() ==# ':' && getcmdline() =~# '^man') ? 'Man' : 'man'
cnoreabbrev <expr> task (getcmdtype() ==# ':' && getcmdline() =~# '^task') ? '!task' : 'task'
