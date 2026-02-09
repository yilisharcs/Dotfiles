{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.aseprite       # Animated sprite editor & pixel art tool
            pkgs.gimp           # GNU Image Manipulation Program
            # pkgs.inkscape
            # pkgs.krita
            pkgs.libreoffice    # Office productivity suite
            ## TODO: home-configuration.nix:programs.obs-studio
            # pkgs.obs-studio   # FOSS program for video recording and live streaming
            # pkgs.picard
            pkgs.vlc            # Cross-platform media player and streaming server
        ];
    }];
}
