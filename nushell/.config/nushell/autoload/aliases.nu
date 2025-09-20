# Editor
alias vi = nvim
alias vim = nvim

# Convenience
alias reboot = systemctl reboot
alias shutdown = systemctl poweroff

alias ":q" = exit
def apgrep [str: string] { apt list --installed e> /dev/null | rg $str }
alias apkg = apt-cache
def h [str: string] { nu -c $"($str) --help" | less -FRX }
alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove

alias brave = brave-browser
alias cz = czkawka_cli
alias fd = fd --hidden
alias fetch = fastfetch
alias grep = rg
alias lx = eza --color=always --group-directories-first --tree
alias pandoc = pandoc --defaults=defaults
alias pomo = porsmo
alias speedtest = speedtest-cli
# alias wiki = wiki-tui
alias yt = yt-dlp

# nushell scripts
alias gitcon = gitcon.nu
# alias gitgrep = gitgrep.nu
alias gitlist = gitlist.nu
alias mask = maskfile.nu
alias tokeicon = tokeicon.nu
alias wut = helpless.nu

# # build from source and stow with incredible ease
# def just [...args] {
#   let project_name = (basename (pwd))
#   let install_prefix = ($"($env.HOME)/stow/($project_name)/.local")
#
#   with-env { CMAKE_BUILD_TYPE: 'Release',
#     CMAKE_INSTALL_PREFIX: $install_prefix,
#     PREFIX: $install_prefix,
#     INSTALL_DIR: $install_prefix } {
#     make -e ...$args
#
#     if $args.0? == "install" {
#       try {
#         stow -d ~/stow $project_name
#       } catch {
#         echo $"Stow failed; files are in ($install_prefix)"
#       }
#     }
#   }
# }
