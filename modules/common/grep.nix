{ lib, pkgs, ... }: let
    inherit (lib) getExe;

    # Me when I don't want grep to waste time with a vcs dir
    grep-wrapped = pkgs.writeShellScriptBin "grep" ''
        exec ${getExe pkgs.gnugrep} --color=auto --exclude-dir={.git,.jj} "$@"
    '';
in {
    home-manager.sharedModules = [{
        home.packages = [ grep-wrapped ];
    }];
}
