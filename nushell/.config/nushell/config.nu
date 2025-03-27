$env.config = {
    show_banner: false

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }

    keybindings: [
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
    ]
}

$env.CMAKE_BUILD_TYPE = 'Release'

$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.DOTFILES = $"($env.HOME)/.dotfiles"

$env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.local/bin")

$env.WASMTIME_HOME = $"($env.HOME)/.wasmtime"
$env.PATH = ($env.PATH | split row (char esep) | prepend $env.WASMTIME_HOME)

# { Language-specific
## Go
$env.GOPATH = $"($env.HOME)/go"
$env.GOBIN = $"($env.GOPATH)/bin"
$env.PATH = ($env.PATH | split row (char esep) | prepend $env.GOBIN)

## Rust
$env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.cargo/bin")

## WebAssembly
$env.WASI_SDK_PATH = $"($env.HOME)/src/wasi-sdk-25.0"
# }

$env.RIPGREP_CONFIG_PATH = $"($env.XDG_CONFIG_HOME)/ripgrep/ripgreprc"
$env.FZF_DEFAULT_COMMAND = "fd --hidden --follow --ignore-case --type file --strip-cwd-prefix --exclude={.cache,.git,.npm,.oh-my-zsh,src}"
$env.FZF_DEFAULT_OPTS = "--preview 'bat --color=always --wrap=never --style=plain --line-range=:500 {}' --layout=reverse --multi --preview-window border-left --bind backward-eof:abort --bind 'F4:change-preview-window(hidden|right)' --bind 'ctrl-j:preview-page-down,ctrl-k:preview-page-up'"
$env.FZF_CTRL_R_OPTS = "--preview 'echo {}' --preview-window hidden --bind 'ctrl-y:execute-silent(echo -n {2..} | xsel -ib)+abort' --header 'Press CTRL-Y to copy command into clipboard'"

$env.EDITOR = 'nvim'
alias vi = nvim
alias vim = nvim
def mvim [] {
    $env.NVIM_APPNAME = 'nvim-minimal'
    nvim
}

alias visudo = sudo visudo
alias yeet = sudo apt-get purge --autoremove
alias tmuxa = tmux attach
alias cargo = cargo auditable

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu
