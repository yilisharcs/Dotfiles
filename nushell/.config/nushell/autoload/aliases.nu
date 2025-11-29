def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo

def apgrep [str: string] { apt list --installed e> /dev/null | rg $str }
alias apkg = apt-cache
alias yeet = sudo apt-get purge --autoremove

alias mask = maskfile.nu
alias pandoc = pandoc.nu
