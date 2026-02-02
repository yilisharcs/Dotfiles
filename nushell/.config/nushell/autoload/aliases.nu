def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo

alias pandoc = pandoc.nu
