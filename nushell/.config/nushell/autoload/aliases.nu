alias ":q" = exit
def apgrep [str: string] { apt list --installed e> /dev/null | rg $str }
alias apkg = apt-cache
def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove

alias eza = eza.nu
alias mask = maskfile.nu
alias pandoc = pandoc.nu
