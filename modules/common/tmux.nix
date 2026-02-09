{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;
in {
    home-manager.sharedModules = [{
        # Terminal multiplexer
        programs.tmux = enabled {
            prefix = "C-t";
            aggressiveResize = true;
            baseIndex = 1; # The objectively correct way to number windows
            clock24 = true;
            escapeTime = 0; # Address vim mode switching delay (http://superuser.com/a/252717/65504)
            focusEvents = true; # Focus events enabled for terminals that support them
            historyLimit = 5000;
            keyMode = "emacs";
            mouse = true;
            newSession = true; # Automatically spawn a session if trying to attach and none are running.
            # shell = "${get Exe pkgs.nushell}";
            terminal = "tmux-256color"; # Set $TERM colors
            extraConfig = ''
                set -g display-time 4000    # Increase tmux messages display duration from 750ms to 4s

                # Status bar and border colors
                set-option -sg terminal-features ',*:RGB' # Fix colors for nvim->tmux->nvim instance
                set -g status-style 'bg=green fg=#000000,bold'
                set-option -g window-status-current-format '[ *#I:#W#F ]'

                set -g status-left-length 0 # no limit to status length
                set -g status-right-length 0
                set -g status-left '[#S] #{user}@#h'
                set -g status-right '[%F]'
                set -g status-justify centre
                set -g status-interval 5
                setw -g automatic-rename on

                # Set Copy-Mode settings
                setw -g mode-keys vi
                setw -g mode-style 'bg=#fab387 fg=#000000'
                bind -T copy-mode-vi 'v' send -X begin-selection
                bind -T copy-mode-vi 'y' send -X copy-pipe-and-cancel '${getExe pkgs.xclip} -sel clip'
            '';
        };
    }];
}
