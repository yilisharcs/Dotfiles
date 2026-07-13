{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [pkgs.tmux-sessionizer];

      xdg.configFile."tms/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
        vcs_providers = [
          "jj"
          "git"
        ];
        shortcuts = {
          "ctrl-h" = "backspace";
        };
        sessions = [
          {
            name = "dot";
            path = "~/Dotfiles";
          }
        ];
        search_dirs = [
          {
            path = "~/Dotfiles/";
            depth = 1;
          }
          {
            path = "~/Projects/";
            depth = 3;
          }
          {
            path = "~/.local/share/nvim/site/pack/core/opt/";
            depth = 1;
          }
          {
            path = "~/Games/";
            depth = 1;
          }
        ];
      };

      programs.tmux.extraConfig =
        /*
        tmux
        */
        ''
          # open picker
          bind 'C-o' display-popup -E "tms"

          # switch to another session interactively, then kill original
          bind 'C-x' run-shell 'tmux display-popup -E "tms switch && tmux kill-session -t #S"'
        '';
    }
  ];
}
