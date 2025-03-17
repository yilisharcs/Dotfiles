export EDITOR="nvim"

export XDG_CONFIG_HOME=$HOME/.config
export DOTFILES=$HOME/.dotfiles

export PATH="$HOME/.local/bin:$PATH"

# ## CMAKE Flags
export CMAKE_BUILD_TYPE=Release

# {
# ## Language-specific
## Rust
export PATH="$HOME/.cargo/bin:$PATH"

## Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# }

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --ignore-case --type file \
    --strip-cwd-prefix --exclude={.cache,.git,.npm,.oh-my-zsh,src}"
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --wrap=never --style=plain \
    --line-range=:500 {}' --layout=reverse --multi --preview-window border-left \
    --bind backward-eof:abort --bind 'F4:change-preview-window(hidden|right)' \
    --bind 'ctrl-j:preview-page-down,ctrl-k:preview-page-up'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden \
    --bind 'ctrl-y:execute-silent(echo -n {2..} | xsel -ib)+abort' \
    --header 'Press CTRL-Y to copy command into clipboard'"

# massren doesn't support ini config
massren --config editor 'nvim -u NONE -c "source ~/.config/massren/massren.vim"' &> /dev/null
