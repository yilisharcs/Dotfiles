# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Download Oh My Zsh, if it's not there yet
if [ ! -d "$ZSH" ]; then
   mkdir -p "$(dirname $ZSH)"
   git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES="robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

zstyle ':omz:*' aliases no

export ZSH_COMPDUMP="$ZSH/cache/.zcompdump"

source $ZSH/oh-my-zsh.sh

# USER CONFIGURATION

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(v|vi|im|vim|exit|[bf]g|ls|pwd|clear)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
    alias {vi}='vim'
else
    export EDITOR='nvim'
    alias {vi,vim}='nvim'
fi

alias visudo='sudo visudo'
alias yeet='sudo apt-get purge --auto-remove'
alias tmuxa='tmux attach'
alias cp='cp -iv' # prompt to overwrite, verbose
alias ls='ls -a --color=auto' # hidden
alias lsa='ls -alh --color=auto' # hidden, readable list
alias rm='rm -I'

alias newlog='log=~/logs/execlog-$(date +%F).md; \
    [[ -f $log ]] && nvim $log || nvim $log -c "r !tail -n 5 ~/logs/blueprint-log.md" \
    -c "g/^$/d" -c "%s/YYYY-MM-DD/\=strftime(\"%F\")"'

alias cargo="cargo auditable"

bindkey -s ^g " tmux-sessionizer\n"
bindkey -s ^z " fg\n"

make() {
  local project_name=$(basename "$(pwd)")
  local install_prefix="$HOME/stow/$project_name/.local"

  mkdir -p "$install_prefix"

  if [[ -f CMakeLists.txt || -d build ]]; then
    command make CMAKE_INSTALL_PREFIX="$install_prefix" "$@"
  elif [[ -f Makefile || -f makefile ]]; then
    command make PREFIX="$install_prefix" prefix="$install_prefix" INSTALL_DIR="$install_prefix" DESTDIR="" "$@"
  else
    command make "$@"
  fi

  if [[ "$1" = "install" ]]; then
    stow -d ~/stow "$project_name" 2>/dev/null || echo "Stow failed; files are in $install_prefix"
  fi
}

source <(fzf --zsh)
source <(zoxide init zsh)

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
