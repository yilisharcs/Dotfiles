{ lib, pkgs, ... }: let
    inherit (lib) getExe';

    cz-cli = pkgs.writeShellScriptBin "cz" ''
        exec ${getExe' pkgs.czkawka "czkawka_cli"} "$@"
    '';
in {
    home-manager.sharedModules = [{
        # Duplicate file finder
        home.packages = [
            cz-cli
            pkgs.czkawka
        ];
    }];
}
