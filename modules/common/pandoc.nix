{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;

    pandoc-wrapped = pkgs.symlinkJoin {
        name = "pandoc";
        paths = [ pkgs.pandoc ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
            rm $out/bin/pandoc
            makeWrapper ${getExe pkgs.pandoc} $out/bin/pandoc \
                --add-flags "--pdf-engine=${getExe pkgs.typst}"
        '';
    };
in {
    home-manager.sharedModules = [{
        # Universal document converter
        programs.pandoc = enabled {
            package = pandoc-wrapped;
        };
    }];
}
