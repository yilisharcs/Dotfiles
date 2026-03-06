{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.aseprite       # Animated sprite editor & pixel art tool
            pkgs.libreoffice    # Office productivity suite
            pkgs.picard         # MusicBrainz tagger
        ];
    }];
}
