$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")

# {
## Rust
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin")
# alias cargo = cargo auditable

# ## JavaScript ## > fnm is installed via cargo, therefore my alphabetical order is ruined
# fnm env --json | from json | load-env
# $env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")

# ## WebAssembly
# $env.WASMTIME_HOME = $"($env.HOME)/.wasmtime" # It's Wasmtime
# $env.PATH = ($env.PATH | prepend $"($env.WASMTIME_HOME)/bin")
# $env.WASI_SDK_PATH = $"($env.HOME)/opt/wasi-sdk-25.0-x86_64-linux-sdk-25.0"
# # }

$env.SQLITE_HISTORY = $"($env.HOME)/.local/state/sqlite3/sqlite_history"

$env.RIPGREP_CONFIG_PATH = $"($env.XDG_CONFIG_HOME)/ripgrep/ripgreprc"

$env.FZF_DEFAULT_COMMAND = "fd --hidden --follow --ignore-case --type file --strip-cwd-prefix --exclude={.cache,.git,.npm}"
$env.FZF_DEFAULT_OPTS = "--preview 'bat --color=always --wrap=never --style=plain --line-range=:500 {}' --layout=reverse --multi --preview-window border-left --bind backward-eof:abort --bind 'F4:change-preview-window(hidden|right)' --bind 'ctrl-j:preview-page-down,ctrl-k:preview-page-up'"

$env.config.show_banner = false

$env.config.history = {
  file_format: plaintext
  max_size: 1_000_000
  sync_on_enter: true
  isolation: false
}

$env.config.plugin_gc = {
  default: {
    enabled: true
    stop_after: 10sec
  }
  plugins: {
    gstat: {
      stop_after: 1min
    }
    inc: {
      stop_after: 0sec
    }
  }
}

$env.config.keybindings = [
  {
    name: tmux_sessionizer
    modifier: control
    keycode: char_g
    mode: [emacs, vi_insert, vi_normal]
    event: {
      send: executehostcommand,
      cmd: "tmux-sessionizer"
    }
  }
  {
    name: job_to_foreground
    modifier: control
    keycode: char_z
    mode: [emacs, vi_insert, vi_normal]
    event: {
      send: executehostcommand,
      cmd: "job unfreeze"
    }
  }
  {
    name: fuzzy_history
    modifier: control
    keycode: char_r
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "commandline edit --replace (
        history
        | get command
        | reverse
        | uniq
        | str join (char -i 0)
        | fzf
        --preview '{}'
        --preview-window 'right:30%'
        --scheme history
        --read0
        --layout reverse
        --height 40%
        --query (commandline)
        | decode utf-8
        | str trim
        )"
      }
    ]
  }
]

$env.config.buffer_editor = 'nvim'
$env.SUDO_EDITOR = 'vim.tiny'
$env.EDITOR = 'nvim'
alias vi = nvim
alias vim = nvim
alias :q = exit
def mvim [...args] {
  with-env { NVIM_APPNAME: 'nvim-minimal' } {
    nvim ...$args
  }
}

## Build from source and stow with incredible ease
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

alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove
alias tmuxa = tmux attach

# Git pretty histogram
def gitcon [] {
  git log --pretty=%h»¦«%aN»¦«%s»¦«%aD
  | lines
  | split column "»¦«" sha1 committer desc merged_at
  | histogram committer merger
  | sort-by count # merger
  | reverse
}

# SSH-agent handler
do --env {
  let ssh_agent_file = (
    $nu.temp-path | path join $"ssh-agent-($env.USER).nuon"
  )

  if ($ssh_agent_file | path exists) {
    let ssh_agent_env = open ($ssh_agent_file)
    if ($"/proc/($ssh_agent_env.SSH_AGENT_PID)" | path exists) {
      load-env $ssh_agent_env
      return
    } else {
      rm $ssh_agent_file
    }
  }

  let ssh_agent_env = ^ssh-agent -c
  | lines
  | first 2
  | parse "setenv {name} {value};"
  | transpose --header-row
  | into record
  load-env $ssh_agent_env
  $ssh_agent_env | save --force $ssh_agent_file
}

# Shell integrations
mkdir ($nu.data-dir | path join "vendor/autoload")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.STARSHIP_LOG = 'error'

zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")
