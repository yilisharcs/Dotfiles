{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [pkgs.tmux-sessionizer];

      home.file.".config/tms/config.toml".source = (pkgs.formats.toml {}).generate "config.toml" {
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
            path = "~/Projects/";
            depth = 3;
          }
          {
            path = "~/.local/share/nvim/site/pack/core/opt/";
            depth = 1;
          }
        ];
      };
    }
  ];
}
