{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Multilanguage implementation of ctags
        home.packages = [ pkgs.universal-ctags ];

        # Terminal text editor
        programs.neovim = enabled {
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
            extraPackages = [
                pkgs.curl             # Command-line tool for transferring files with URL syntax
                pkgs.gcc              # Needed to compile treesitter parsers
                pkgs.jq               # Command-line JSON processor
                pkgs.tree-sitter      #FIXME: tree-sitter version is outdated: v25.x not v26.5
                (pkgs.symlinkJoin {   # lazy.nvim dependency for dealing with rockspecs
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
