{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;

  # TODO: remove once `https://github.com/neovim/neovim/pull/36262` is merged
  neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patch/0001-feat-undo-re-sync-undo-files-on-external-change.patch
        ./patch/0002-feat-undo-add-check-for-large-undo-files.patch
        ./patch/0003-docs-new-backup-behavior.patch
        ./patch/0004-fix-undo-abort-buffer-replace-if-file-is-readonly.patch
      ];
  });

  # NOTE: these $XDG_ vars pollute the runtimepath, which can cause a
  #       noticeable slowdown. TODO: consider upstreaming this.
  neovim =
    (pkgs.symlinkJoin {
      name = "neovim";
      paths = [neovim-unwrapped];
      nativeBuildInputs = [pkgs.makeWrapper];
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
            '
      '';
    })
    // {
      meta =
        (neovim-unwrapped.meta or {})
        // {
          mainProgram = "nvim";
          priority = (neovim-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
        };
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
        extraPackages = [
          pkgs.curl # Command-line tool for transferring files with URL syntax
          pkgs.gcc # NOTE: Needed to compile treesitter parsers
          pkgs.jq # Lightweight JSON processor
          pkgs.tree-sitter
        ];
      };

      home.sessionVariables = {
        SUDO_EDITOR = "nvim";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
      };
    }
  ];
}
