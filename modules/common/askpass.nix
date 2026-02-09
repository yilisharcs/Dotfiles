{ lib, pkgs, ... }: let
    inherit (lib) getExe;

    zenity-askpass = pkgs.writeShellScriptBin "zenity-askpass" ''
        ${getExe pkgs.zenity} --password --title="[sudo] password for $USER"
    '';
in {
    home-manager.sharedModules = [{
        home.packages = [ zenity-askpass ];

        home.sessionVariables = {
            SUDO_ASKPASS = "${zenity-askpass}/bin/zenity-askpass";
        };
    }];
}
