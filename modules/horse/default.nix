{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.aseprite       # Animated sprite editor & pixel art tool
            pkgs.libreoffice    # Office productivity suite
            ## TODO: home-configuration.nix:programs.obs-studio
            # pkgs.obs-studio   # FOSS program for video recording and live streaming
            # pkgs.picard
        ];
    }];
}
