{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe getExe';

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

  man-orig = getExe' pkgs.man-db "man";
  man-wrapper =
    (pkgs.writeShellScriptBin "man" ''
      if [ -t 1 ]; then
        exec ${getExe neovim} -c "Man $*" -c "only"
      else
        exec ${man-orig} "$@"
      fi
    '').overrideAttrs (old: {
      meta = (old.meta or {}) // {priority = 4;};
    });
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.universal-ctags # Multilanguage implementation of ctags
        man-wrapper
      ];

      # Terminal text editor
      programs.neovim = enabled {
        package = neovim;
        sideloadInitLua = true; # Don't overwrite $XDG_CONFIG_HOME/nvim/init.lua stow symlink
        initLua =
          /*
          lua
          */
          ''
            -- restore system XDG paths for child processes (xdg-open, etc.)
            -- this doesn't affect RTP because it's already been calculated.
            if vim.env._OLD_XDG_DATA_DIRS then
              vim.env.XDG_DATA_DIRS = vim.env._OLD_XDG_DATA_DIRS
            end
            if vim.env._OLD_XDG_CONFIG_DIRS then
              vim.env.XDG_CONFIG_DIRS = vim.env._OLD_XDG_CONFIG_DIRS
            end
          '';
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
  };
}
