{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;

  neovim = pkgs.symlinkJoin {
    inherit (pkgs.neovim-unwrapped) version;
    pname = "neovim";
    paths = [pkgs.neovim-unwrapped];
    nativeBuildInputs = [pkgs.makeWrapper];
    meta =
      (pkgs.neovim-unwrapped.meta or {})
      // {
        mainProgram = "nvim";
        priority = (pkgs.neovim-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
      };
    # NOTE: these $XDG_ vars pollute the runtimepath, which can cause a noticeable slowdown
    # TODO: consider upstreaming this
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --run '
          filter_xdg() (
            IFS=:
            new_dirs=""
            for d in $1; do
                [ -d "$d/nvim" ] && new_dirs="''${new_dirs:+$new_dirs:}$d"
            done
            echo "$new_dirs"
          )
          export _OLD_XDG_DATA_DIRS="$XDG_DATA_DIRS"
          export _OLD_XDG_CONFIG_DIRS="$XDG_CONFIG_DIRS"
          export XDG_DATA_DIRS=$(filter_xdg "$XDG_DATA_DIRS")
          export XDG_CONFIG_DIRS=$(filter_xdg "$XDG_CONFIG_DIRS")

          if [ -x "$HOME/opt/neovim/bin/nvim" ]; then
            exec "$HOME/opt/neovim/bin/nvim" "$@"
          fi
        '
    '';
  };
in {
  home-manager.sharedModules = [
    {
      # Multilanguage implementation of ctags
      home.packages = [pkgs.universal-ctags];

      # Terminal text editor
      programs.neovim = enabled {
        package = neovim;
        sideloadInitLua = true; # Don't overwrite $XDG_CONFIG_HOME/nvim/init.lua stow symlink
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withPython3 = false;
        withRuby = false;
        extraPackages = let
          treesitter-plugin = [
            pkgs.tree-sitter
            pkgs.gcc # NOTE: Needed to compile parsers
          ];
        in
          [
            pkgs.curl # Command-line tool for transferring files with URL syntax
            pkgs.jq # Lightweight JSON processor
          ]
          ++ treesitter-plugin;
      };
    }
  ];

  environment.sessionVariables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
