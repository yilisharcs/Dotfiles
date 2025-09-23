# Convenience
alias reboot = systemctl reboot
alias shutdown = systemctl poweroff

alias ":q" = exit
def apgrep [str: string] { apt list --installed e> /dev/null | rg $str }
alias apkg = apt-cache
def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove

# FIXME: trying to call from a wrapper script causes a memory leak??
alias pandoc = pandoc --defaults=defaults

# nushell scripts
alias mask = maskfile.nu
alias wut = helpless.nu
