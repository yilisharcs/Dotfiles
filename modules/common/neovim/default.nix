{ lib, pkgs, ... }: let
    inherit (lib) enabled;

    # TODO: remove once `https://github.com/neovim/neovim/pull/36262` is merged
    neovim = pkgs.neovim-unwrapped.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
            ./patch/0001-feat-undo-re-sync-undo-files-on-external-change.patch
            ./patch/0002-feat-undo-add-check-for-large-undo-files.patch
            ./patch/0003-docs-new-backup-behavior.patch
        ];
    });
in {
    home-manager.sharedModules = [{
        # Multilanguage implementation of ctags
        home.packages = [ pkgs.universal-ctags ];

        # Terminal text editor
        programs.neovim = enabled {
            package = neovim;
            sideloadInitLua = true;     # Don't overwrite $XDG_CONFIG_HOME/nvim/init.lua stow symlink
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            withPython3 = false;
            withRuby = false;
            extraPackages = [
                pkgs.curl               # Command-line tool for transferring files with URL syntax
                pkgs.gcc                # NOTE: Needed to compile treesitter parsers
                pkgs.jq                 # Lightweight JSON processor
                pkgs.tree-sitter
                (pkgs.symlinkJoin {     # lazy.nvim dependency for dealing with rockspecs
                    name = "luarocks_lua51";
                    paths = [
                        pkgs.lua51Packages.luarocks
                        pkgs.lua5_1
                    ];
                })
            ];
        };

        home.sessionVariables = {
            SUDO_EDITOR = "nvim";
            EDITOR      = "nvim";
            MANPAGER    = "nvim +Man!";
        };
    }];
}
