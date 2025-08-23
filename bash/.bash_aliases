# Editor
alias {vi,vim}="nvim"

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

alias brave="brave-browser"
alias fd="fd --hidden"
alias fetch="fastfetch"
alias grep="rg"
alias lx="eza --color=always --group-directories-first --tree"
alias pomo="porsmo"
alias speedtest="speedtest-cli"
# alias wiki="wiki-tui"
alias yt="yt-dlp"

# nushell scripts
alias gitcon="gitcon.nu"
# alias gitgrep="gitgrep.nu"
alias gitlist="gitlist.nu"
alias mask="maskfile.nu"
alias tokeicon="tokeicon.nu"
