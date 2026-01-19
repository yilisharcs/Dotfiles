def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo

alias mask = maskfile.nu
alias pandoc = pandoc.nu
