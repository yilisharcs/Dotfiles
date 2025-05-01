#!/usr/bin/env nu

# Stow symlinks whole dirs if they don't exist. Without this,
# the system will cram stuff where it isn't supposed to go.
[
  .cargo
  .config
  .local/bin
  .local/include
  .local/lib
  .local/share/icons/hicolor/128x128/apps
  .local/share/nvim/lazy
  .local/share/nvim/mason
  .local/share/man/man1
  .local/state
  opt
  stow
] | each {|e| $env.HOME | path join $e | mkdir $in }

# Symlinks that stow can't automate
{
  ## Dirs
  $"($env.HOME)/.local/share/Trash": $"($env.HOME)/Trash",

  ## Bins
  $"(^which batcat)": $"($env.HOME)/.local/bin/bat",
  $"(^which fdfind)": $"($env.HOME)/.local/bin/fd",
} | items {|k, v|
  if ( ($v) | path exists ) {
    print $'(ansi green_bold)  Symlink (ansi yellow_bold)($v) (ansi green_bold)already exists.(ansi reset)'
  } else {
    ln -s ($k) ($v)
  }
} | ignore

##################
### DEBIAN-APT ###
##################

[
  atool                          # compression and extraction tools
  bat                            # better cat
  bibata-cursor-theme
  btop                           # tui system monitor
  chafa                          # terminal image visualizer
  cmus                           # tui music player
  dconf-editor
  fd-find                        # better find
  ffmpeg
  ffmpegthumbnailer
  fzf                            # fuzzy finder
  gnome-boxes                    # virtualization
  gnome-shell-extension-manager
  hunspell-en-us
  hunspell-pt-br
  imagemagick
  inkscape                       # image editor
  krita                          # image editor
  lf                             # tui file explorer
  mesa-utils                     # gpu utils
  ncdu                           # disk space checker
  pass                           # cli password manager
  picard                         # music metadata editor
  preload                        # fetch frequently-used binaries to ram
  qbittorrent
  ripgrep                        # better grep
  starship                       # shell prompt tool
  stow                           # symlink manager
  syncthing                      # peer-to-peer file sync
  timeshift
  trash-cli
  tree                           # dir viewer
  xclip                          # in use because wl-clip creates a window to access the clipboard
  yt-dlp
  zoxide                         # better cd

  # gnome-extension deps
  gir1.2-gtop-2.0                # vitals
  lm-sensors                     # vitals

  # dev libs and tools
  bacon                          # background code checker
  build-essential                # provides gnu make
  cmake
  curl
  file
  freeglut3-dev
  g++-multilib
  gcc-mingw-w64
  gcc-multilib
  gettext
  gh                             # github cli client
  git
  libasound2-dev
  libayatana-appindicator3-dev
  libbz2-dev
  libcrypto++-dev
  libexpat1-dev
  libfontconfig1-dev
  libfreetype6-dev
  libmagic-dev
  librsvg2-dev
  libsndio-dev
  libssl-dev
  libudev-dev
  libwayland-dev
  libwebkit2gtk-4.1-dev
  libxcb-composite0-dev
  libxcursor-dev
  libxdo-dev
  libxi-dev
  libxmu-dev
  ninja-build
  pipx                           # python package manager
  pkg-config
  rustup                         # rust toolchain manager
  sccache                        # build cache tool
  sqlite3
  tmux
  tokei                          # loc counter
  wget
  yq                             # cli json, yaml, and xml processor
] | sudo apt install -y ...$in

####################
### RUST-N-CARGO ###
####################

rustup component add rust-analyzer
rustup target install wasm32-unknown-unknown

# FIXME: eval fails in the block below if --git $crate is a string
cargo install --git https://github.com/neovide/neovide

[
  # cargo-audit
  # cargo-auditable
  cargo-binstall
  cargo-modules
  # cargo-nextest
  # cargo-sweep
  cargo-update
  dioxus-cli
  fnm
  ra-multiplex
] | cargo install ...$in | ignore

##################
### NU-PLUGINS ###
##################

[
  /usr/libexec/nushell/nu_plugin_gstat
  /usr/libexec/nushell/nu_plugin_inc
  /usr/libexec/nushell/nu_plugin_query
] | each { plugin add $in } | ignore
echo $'(ansi blue_bold)    Added Nushell plugins!(ansi reset)'

###############
### DEV-ENV ###
###############

sudo update-alternatives --set editor /usr/bin/vim.tiny
