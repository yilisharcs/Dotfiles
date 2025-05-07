##############
### CONFIG ###
##############

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
    gstat: { stop_after: 1min }
    inc: { stop_after: 0sec }
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
        | sk
        --read0
        --layout reverse
        --query (commandline)
        --bind=ctrl-y:(echo {} | wl-copy)+abort
        | decode utf-8
        | str trim
        )"
      }
    ]
  }
]

$env.config.buffer_editor = 'nvim'

###############
### ALIASES ###
###############

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

####################
### INTEGRATIONS ###
####################

mkdir ($nu.data-dir | path join "vendor/autoload")

fnm env --json | from json | load-env
$env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.STARSHIP_LOG = 'error'

zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

# my entries are being duplicated and I don't want to debug that
$env.PATH = ($env.PATH | uniq)
