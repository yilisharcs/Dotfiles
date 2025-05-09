# editor muscle memory
alias vi = nvim
alias vim = nvim
alias ":q" = exit

# convenience
def apgrep [str: string] { apt list --installed e> /dev/null | rg $str }
alias apkg = apt-cache
alias brave = brave-browser
alias fetch = fastfetch
alias pomo = porsmo
alias speedtest = speedtest-rs
alias visudo = sudo visudo
alias wiki = wiki-tui
alias yeet = sudo apt-get purge --autoremove

# nushell scripts
alias gitcon = gitcon.nu
alias gitlist = gstat.nu
alias tokeicon = tokeicon.nu

# build from source and stow with incredible ease
def just [...args] {
  let project_name = (basename (pwd))
  let install_prefix = ($"($env.HOME)/stow/($project_name)/.local")

  with-env { CMAKE_BUILD_TYPE: 'Release',
    CMAKE_INSTALL_PREFIX: $install_prefix,
    PREFIX: $install_prefix,
    INSTALL_DIR: $install_prefix } {
    make -e ...$args

    if $args.0? == "install" {
      try {
        stow -d ~/stow $project_name
      } catch {
        echo $"Stow failed; files are in ($install_prefix)"
      }
    }
  }
}

# explore, with tables!
# TODO: add a --find flag (it's harder than it sounds)
def wut [...arg: string] {
  match $arg {
    aliases => { help aliases | explore }
    commands => { help commands | explore }
    escapes => { help operators | explore }
    externs => { help externs | explore }
    modules => { help modules | explore }
    operators => { help operators | explore }
    pipe-and-redirect => { help pipe-and-redirect | explore }
    null => { help | less -R }
    _ => { help ...$arg | less -R }
  }
}
