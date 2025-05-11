# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

# set user-specific configuration variable
export XDG_CONFIG_HOME="$HOME/.config"

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"

export SKIM_DEFAULT_COMMAND="fd --color=never --hidden --follow --type f --type l --exclude .git"
export SKIM_DEFAULT_OPTIONS="--bind='ctrl-j:preview-page-down,ctrl-k:preview-page-up' \
  --layout=reverse --multi --bind='F4:toggle-preview,ctrl-h:backward-char+delete-charEOF' \
  --preview 'bat {} --color=always --wrap=never --style=plain --line-range=:500'"

# set sqlite histfile elsewhere instead of HOME
export SQLITE_HISTORY="$HOME/.local/state/sqlite3/sqlite_history"

# disable "command timed-out" prompt errors
export STARSHIP_LOG="error"

export ZK_NOTEBOOK_DIR="$HOME/notebook"

# {

# bob-nvim
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# Golang
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

## Rust
export PATH="$HOME/.cargo/bin:$PATH"

# }

export SUDO_EDITOR=vim.tiny
export EDITOR=nvim
export MANPAGER="nvim +Man!"
export LESS="-FRX"
