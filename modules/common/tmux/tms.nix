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
            name = "S3AIR-Limoeiro";
            # NOTE: why doesn't every window inherit the path? that's kind of ridiculous.
            path = "~/Projects/github.com/yilisharcs/S3AIR-Limoeiro";
            windows = [
              {
                name = "opencode";
                path = "~/Projects/github.com/yilisharcs/S3AIR-Limoeiro";
                command = "opencode";
              }
              {
                name = "vim";
                path = "~/Projects/github.com/yilisharcs/S3AIR-Limoeiro";
                command = "vim";
              }
              {
                name = "games";
                path = "~/Games/.games";
                command = "vim -c 'lua require(\"mini.sessions\").read(\".games.vim\")'";
              }
              {
                name = "woncord";
                command = "woncord";
              }
            ];
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
          bind 'C-x' run-shell 'tmux display-popup -E "tms switch; tmux kill-session -t #S"'
        '';
    }
  ];
}
