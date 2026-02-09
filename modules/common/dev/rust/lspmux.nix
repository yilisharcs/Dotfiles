{ pkgs, lib, ... }: let
    inherit (lib) getExe mkIf;
in {
    home-manager.sharedModules = [({ config, ... }: let
        rustEnabled = config.programs.cargo.enable or false;
    in mkIf rustEnabled {
        home.file.".config/lspmux/config.toml".source = ./lspmux.toml;

        home.packages = [ pkgs.lspmux ];
        systemd.user.services.lspmux = {
            Unit = {
                Description = "LSP multiplexer server";
                After = [ "network.target" ];
            };
            Service = {
                Type = "simple";
                ExecStart = "${getExe pkgs.lspmux} server";
                Restart = "on-failure";
                RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
        };
    })];
}
