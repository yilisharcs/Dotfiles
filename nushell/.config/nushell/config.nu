$env.config.show_banner = false

$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000
    sync_on_enter: true
    isolation: false
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
]

$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.DOTFILES = $"($env.HOME)/.dotfiles"

$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")

# {
## C/C++
$env.CMAKE_BUILD_TYPE = 'Release'
def smake [...args] {
    let project_name = (basename (pwd))
    let install_prefix = ($"($env.HOME)/stow/($project_name)/.local")

    mkdir $install_prefix

    if ("CMakeLists.txt" | path exists) or ("build" | path exists; ("build" | path type) == "dir") {
        make $env.CMAKE_INSTALL_PREFIX=$install_prefix ...$args
    } else if ("Makefile" | path exists) or ("makefile" | path exists) {
        make $env.PREFIX=$install_prefix $env.INSTALL_DIR=$install_prefix $env.DESTDIR="" ...$args
    } else {
        make ...$args
    }

    if $args.0? == "install" {
        try {
            stow -d ~/stow $project_name
        } catch {
            echo $"Stow failed; files are in ($install_prefix)"
        }
    }
}

## Go
$env.GOPATH = $"($env.HOME)/go"
$env.GOBIN = $"($env.GOPATH)/bin"
$env.PATH = ($env.PATH | prepend $env.GOBIN)

## Rust
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin")
alias cargo = cargo auditable

## JavaScript ## > fnm is installed via cargo, therefore my alphabetical order is ruined
fnm env --json | from json | load-env
$env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")

## WebAssembly
$env.WASMTIME_HOME = $"($env.HOME)/.wasmtime" # It's Wasmtime
$env.PATH = ($env.PATH | prepend $env.WASMTIME_HOME)
$env.WASI_SDK_PATH = $"($env.HOME)/src/wasi-sdk-25.0"
# }

$env.RIPGREP_CONFIG_PATH = $"($env.XDG_CONFIG_HOME)/ripgrep/ripgreprc"
$env.FZF_DEFAULT_COMMAND = "fd --hidden --follow --ignore-case --type file --strip-cwd-prefix --exclude={.cache,.git,.npm,.oh-my-zsh,src}"
$env.FZF_DEFAULT_OPTS = "--preview 'bat --color=always --wrap=never --style=plain --line-range=:500 {}' --layout=reverse --multi --preview-window border-left --bind backward-eof:abort --bind 'F4:change-preview-window(hidden|right)' --bind 'ctrl-j:preview-page-down,ctrl-k:preview-page-up'"

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

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu
