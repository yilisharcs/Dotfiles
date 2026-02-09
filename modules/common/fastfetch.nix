{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;

    fetch = pkgs.writeShellScriptBin "fetch" ''
        exec ${getExe pkgs.fastfetch} "$@"
    '';
in {
    home-manager.sharedModules = [{
        # Neofetch-like system information tool. It comes in handy occasionally.
        home.packages = [ fetch ];
        programs.fastfetch = enabled {
            settings.modules = [
                { type = "title"; }
                { type = "separator"; }
                { type = "os"; }
                { type = "host"; }
                { type = "kernel"; }
                { type = "uptime"; }
                { type = "packages"; }
                { type = "shell"; }
                { type = "display"; }
                { type = "de"; }
                { type = "wm"; }
                { type = "cpu"; }
                { type = "gpu"; }
                { type = "memory"; }
                { type = "swap"; }
                { type = "disk"; }
                { type = "break"; }
                { type = "colors"; }
            ];
        };
    }];
}
