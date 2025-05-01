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

export XDG_CONFIG_HOME="$HOME/.config"

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --ignore-case --type file \
  --strip-cwd-prefix --exclude={.cache,.git,.npm}"
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --wrap=never --style=plain \
  --line-range=:500 {}' --layout=reverse --multi --preview-window border-left \
  --bind backward-eof:abort --bind 'F4:change-preview-window(hidden|right)' \
  --bind 'ctrl-j:preview-page-down,ctrl-k:preview-page-up'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xsel -ib)+abort' \
  --header 'Press CTRL-Y to copy command into clipboard'"

export SQLITE_HISTORY="$HOME/.local/state/sqlite3/sqlite_history"

export STARSHIP_LOG="error"

# {

## Rust
export PATH="$HOME/.cargo/bin:$PATH"

# }

export SUDO_EDITOR=vim.tiny
export EDITOR=nvim
export MANPAGER="nvim +Man!"
