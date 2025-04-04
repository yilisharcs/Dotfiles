setlocal signcolumn=no
setlocal nonu nornu
setlocal winhighlight+=Search:Transparent,Normal:NormalNC

packadd cfilter

call matchadd('DiagnosticError', '|E|')
call matchadd('DiagnosticWarn', '|W|')
call matchadd('DiagnosticInfo', '|I|')
call matchadd('DiagnosticHint', '|H|')
call matchadd('DiagnosticError', '')
call matchadd('DiagnosticWarn', '')
call matchadd('DiagnosticInfo', '')
call matchadd('DiagnosticHint', '󰞏')
