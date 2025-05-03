# editor muscle memory
alias {vi,vim}="nvim"
alias :q="exit"

# guard-rails
alias cp="cp -iv"
alias rm="rm -I"

# convenience
alias apkg="apt-cache"
alias apgrep="apt list --installed 2> /dev/null | rg"
alias brave="brave-browser"
alias fetch="fastfetch"
alias visudo="sudo visudo"
alias yeet="sudo apt-get purge --auto-remove"

# shortcuts
bind -x '"\C-g":"tmux-sessionizer"'
bind    '"\C-o": edit-and-execute-command'

# nushell scripts
alias gitcon="gitcon.nu"
alias gstat="gstat.nu"
alias tokeicon="tokeicon.nu"
