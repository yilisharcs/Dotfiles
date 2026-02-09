{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;
in {
    home-manager.sharedModules = [{
        # cat(1) with syntax highlighting and git integration
        #
        # Provides a nifty pager that plays nice with one of my neovim plugins.
        programs.bat = enabled {
            config = {
                pager = "${getExe pkgs.less} -FR --mouse";
                map-syntax = [
                    "*.rockspec:Lua"
                    "*.zig.zon:Zig"
                ];
            };
        };
    }];
}
