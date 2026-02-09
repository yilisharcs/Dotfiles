{ pkgs, ... }: {
    home-manager.sharedModules = [{
        ## TODO: configuration.nix:services.qbittorrent
        home.packages = [ pkgs.qbittorrent ];

        xdg.configFile."qBittorrent/themes/catppuccin-mocha.qbtheme".source = ./themes/catppuccin-mocha.qbtheme;
    }];
}
