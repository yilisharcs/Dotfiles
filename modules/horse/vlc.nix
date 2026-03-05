{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.vlc            # Cross-platform media player and streaming server
            pkgs.mediainfo      # Supplies technical and tag info about a video or audio file
        ];

        programs.yazi.settings.opener = {
            play = [
                { desc = "Open with VLC";   run = ''vlc "$@"'';            orphan = true; for = "unix"; }
                { desc = "Show media info"; run = ''mediainfo "$1" | bat''; block = true; for = "unix"; }
            ];
        };
    }];
}
