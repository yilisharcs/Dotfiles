{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe;

  tmug = pkgs.writeShellScriptBin "tmug" ''
    tmux new -A -s "$1"
  '';
in {
  home-manager.sharedModules = [
    {
      home.packages = [tmug];

      # Terminal multiplexer
      programs.tmux = enabled {
        prefix = "C-Space";
        aggressiveResize = true;
        baseIndex = 1; # The objectively correct way to number windows
        clock24 = true;
        escapeTime = 0; # Address vim mode switching delay (http://superuser.com/a/252717/65504)
        focusEvents = true; # Focus events enabled for terminals that support them
        historyLimit = 5000;
        mouse = true;
        terminal = "tmux-256color"; # Set $TERM colors
        extraConfig = let
          sw = lib.colors.silverwine;
        in
          /*
          tmux
          */
          ''
            # kmscon's terminfo doesn't declare italics support; render italics anyway
            set -ga terminal-overrides ',kmscon*:sitm=\E[3m,ritm=\E[23m'

            set -g renumber-windows on
            set -g display-time 4000    # increase tmux messages display duration from 750ms to 4s
            # vi for copy-mode, emacs for command prompt
            set -g status-keys emacs
            setw -g mode-keys vi

            # status bar and border colors
            set -g status-style 'bg=default fg=${sw.blue},bold'
            set -g message-style 'bg=${sw.black} fg=${sw.cyan},bold'
            set -g pane-active-border-style fg=${sw.green}
            set-option -g window-status-current-format '[ *#I:#W#F ]'
            set -g window-status-current-style fg=${sw.yellow},bold

            set -g status-left-length 0 # no limit to status length
            set -g status-right-length 0
            set -g status-left '[#S] #{user}@#h'
            set -g status-right '[%F %R]'
            set -g status-justify centre
            set -g status-interval 5
            setw -g automatic-rename on

            # set copy-mode and clipboard settings
            set -g set-clipboard external
            set -g allow-passthrough off  # block silent clipboard hijack via OSC52
            setw -g mode-style 'bg=${sw.darkGrey} fg=${sw.black}'
            bind -T copy-mode-vi 'v' send -X begin-selection
            bind -T copy-mode-vi 'y' send -X copy-pipe-and-cancel '${getExe pkgs.xclip} -sel clip'

            # smart pane switching with awareness of Vim splits.
            # see: https://github.com/christoomey/vim-tmux-navigator
            # NOTE: neovim is .nvim-wrapped on nixos; regex is updated accordingly
            is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
                | grep -iqE '^[^TXZ ]+ +(\\\\S+\\\\/)?g?\\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?$'"
            bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  { if -F '#{pane_at_left}'   ''' 'select-pane -L' }
            bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  { if -F '#{pane_at_bottom}' ''' 'select-pane -D' }
            bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  { if -F '#{pane_at_top}'    ''' 'select-pane -U' }
            bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  { if -F '#{pane_at_right}'  ''' 'select-pane -R' }

            bind -T copy-mode-vi 'M-h' if -F '#{pane_at_left}'   ''' 'select-pane -L'
            bind -T copy-mode-vi 'M-j' if -F '#{pane_at_bottom}' ''' 'select-pane -D'
            bind -T copy-mode-vi 'M-k' if -F '#{pane_at_top}'    ''' 'select-pane -U'
            bind -T copy-mode-vi 'M-l' if -F '#{pane_at_right}'  ''' 'select-pane -R'

            # run tmux-sessionizer
            bind 'C-o' display-popup -E "tms"

            bind 'X' kill-session
            bind 'C-^' last-window # Vim-like pane switching
            bind 'a' choose-tree -Zs

            # pane control
            bind 'h' split-window -v
            bind 's' split-window -h

            bind -r '-' resize-pane -D 4
            bind -r '+' resize-pane -U 4
            bind -r '<' resize-pane -L 8
            bind -r '>' resize-pane -R 8

            bind 't' break-pane
            bind 'M-t' 'break-pane; last-window'
            bind 'T' 'select-pane -m; last-window; join-pane -h'

            # re-order windows
            bind -n 'C-Left'  'swap-window -t -1; select-window -t -1'
            bind -n 'C-Right' 'swap-window -t +1; select-window -t +1'
          '';
      };
    }
  ];
}
