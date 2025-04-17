setlocal signcolumn=no
setlocal nolist
setlocal nonu nornu
setlocal winhighlight+=Normal:NormalNC,qfLineNr:Number

packadd cfilter

call matchadd('DiagnosticError', '|E|')
call matchadd('DiagnosticWarn', '|W|')
call matchadd('DiagnosticInfo', '|I|')
call matchadd('DiagnosticHint', '|H|')
call matchadd('DiagnosticError', '')
call matchadd('DiagnosticWarn', '')
call matchadd('DiagnosticInfo', '')
call matchadd('DiagnosticHint', '󰞏')
