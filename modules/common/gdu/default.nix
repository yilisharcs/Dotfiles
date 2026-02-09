{ pkgs, ... }: {
    home-manager.sharedModules = [{
        # Disk space analyzer
        home.packages = [ pkgs.gdu ];

        home.file.".config/gdu/gdu.yaml".source = ./gdu.yaml;
    }];
}
