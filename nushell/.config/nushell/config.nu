$env.config.show_banner = false

$env.config.history = {
  file_format: plaintext
  max_size: 10_000_000
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
alias vi = nvim
alias vim = nvim
alias ":q" = exit

alias brave = brave-browser
alias fetch = fastfetch
alias tmuxa = tmux attach
alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove

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

# git pretty histogram
def gitcon [] {
  git log --pretty=%h»¦«%aN»¦«%s»¦«%aD
  | lines
  | split column "»¦«" sha1 committer desc merged_at
  | histogram committer merger
  | sort-by count # merger
  | reverse
}

# percentage of language in a codebase
def tokeicon [] {
  tokei --hidden --compact --sort code
  | lines
  | where $it !~ '='
  | str trim
  | split column --regex '\s\s+'
  | rename ...($in | first | values)
  | skip 1
  | drop
  | update Code {|e| $e.Code | into int }
  | do {
    let total = ($in | get Code | math sum)
    $in | insert Percent {|e| ($e.Code * 100 / $total)}
  }
  | where Code > 0
  | select Language Code Percent
}

# starts ssh-agent if another program hasn't done so
do --env {
  if not ($env.SSH_AUTH_SOCK | is-empty) {
    return
  }

  let ssh_agent_file = (
    $nu.temp-path | path join $"ssh-agent-($env.USER? | default $env.USERNAME).nuon"
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

# shell integrations
mkdir ($nu.data-dir | path join "vendor/autoload")

fnm env --json | from json | load-env
$env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.STARSHIP_LOG = 'error'

zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

# my entries are being duplicated and I don't want to debug that
$env.PATH = ($env.PATH | uniq)
