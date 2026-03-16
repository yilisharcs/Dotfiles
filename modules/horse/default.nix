{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.aseprite       # Animated sprite editor & pixel art tool
            pkgs.picard         # MusicBrainz tagger
        ];
    }];
}
