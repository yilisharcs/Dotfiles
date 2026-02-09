{ lib, pkgs, ... }: let
    inherit (lib) disabled enabled;
in {
    documentation = {
        dev  = enabled;
        doc  = enabled;
        info = disabled;
        man  = enabled {
            generateCaches = true;
        };
    };


    home-manager.sharedModules = [{
        # Linux manpages
        home.packages = [ pkgs.man-pages ];
    }];
}
