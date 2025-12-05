# config.nu
#
# Installed by:
# version = "0.106.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.SUDO_PROMPT = $'(ansi red_bold)[sudo](ansi reset) password for %u: '

# Settings
$env.config = {
        show_banner: false
        buffer_editor: "nvim"
        display_errors: {
                termination_signal: false
        }
        history: {
                file_format: plaintext
                max_size: 10_000_000
                sync_on_enter: true
                isolation: false
        }
        plugin_gc: {
                default: {
                        enabled: true
                        stop_after: 10sec
                }
                plugins: {
                        gstat: { stop_after: 1min }
                        inc: { stop_after: 0sec }
                }
        }
}

# Integrations
$env.config.hooks.env_change.PWD = [
        {||
                if (which direnv | is-empty) { return }
                direnv export json | from json | default {} | load-env
        }
]

mkdir ($nu.data-dir | path join "vendor/autoload")

# FIXME: missing completions for bob
# https://github.com/MordechaiHadad/bob/pull/320
# bob complete nu | save -f ($nu.data-dir | path join "vendor/autoload/bob.nu")

carapace _carapace nushell | save -f ($nu.data-dir | path join "vendor/autoload/carapace.nu")
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

if ($env.FNM_MULTISHELL_PATH? | is-empty) {
        fnm env --json | from json | load-env
        $env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")
}

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

# Yazi shell wrapper
def --env yf [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXXX")
        yazi ...$args --cwd-file $tmp
        let cwd = (open $tmp)
        if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
        }
        rm -fp $tmp
}
