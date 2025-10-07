# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
        PATH="$HOME/.local/bin:$PATH"
fi

# See bash(1) for more options
export HISTCONTROL=ignoreboth   # don't put duplicate lines or lines starting with space in the history.
export HISTSIZE=1000
export HISTFILESIZE=2000

# {

# # Golang
# export GOPATH="$HOME/go"
# export GOBIN="$GOPATH/bin"
# export PATH="$GOBIN:$PATH"

## Rust
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library/

# }

export XDG_CONFIG_HOME="$HOME/.config"                             # set user config directory
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"       # create ripgrep config pointer
export SQLITE_HISTORY="$HOME/.local/state/sqlite3/sqlite_history"  # set sqlite histfile location
export STARSHIP_LOG="error"                                        # disable "command timed-out" errors
export XCOMPOSEFILE="/usr/share/keyd/keyd.compose"                 # keyd compat file for non-ASCII characters
export ZK_NOTEBOOK_DIR="$HOME/notebook"                            # default path to zk files

export GEMINI_MODEL="gemini-2.5-flash"                             # NOTE: remove once json config is fixed upstream

export FZF_DEFAULT_COMMAND="fd --color=never --ignore-case --strip-cwd-prefix \
        --hidden --follow --type f --type l --exclude={.git,.jj,.cache,.npm}"
export FZF_DEFAULT_OPTS="--layout=reverse --multi \
        --preview 'bat {} --color=always --wrap=never --style=plain --line-range=:500' \
        --bind='backward-eof:abort' \
        --bind='F4:toggle-preview' \
        --bind='ctrl-j:preview-page-down' \
        --bind='ctrl-k:preview-page-up'"
export FZF_CTRL_R_OPTS="--preview-window=hidden \
        --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort' \
        --header 'Press CTRL-Y to copy command into clipboard'"

export SUDO_EDITOR=nvim
export EDITOR=nvim
export MANPAGER="nvim +Man!"

# if running bash
if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
                . "$HOME/.bashrc"
        fi
fi
