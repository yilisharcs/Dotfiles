# Guard-rails
alias cp="cp -iv"
alias rm="rm -I"

# Convenience
alias reboot="systemctl reboot"
alias shutdown="systemctl poweroff"

alias :q="exit"
alias ".."="cd .."
alias apgrep="apt list --installed 2> /dev/null | rg"
alias apkg="apt-cache"
alias visudo="sudo visudo"
alias yeet="sudo apt-get purge --autoremove"

# nushell scripts
alias mask="maskfile.nu"
