{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;

    yt = pkgs.writeShellScriptBin "yt" ''
        exec ${getExe pkgs.yt-dlp} "$@"
    '';
in {
    home-manager.sharedModules = [{
        # CLI audio/video downloader for youtube and other sites
        home.packages = [ yt ];
        programs.yt-dlp = enabled {
            settings = {
                no-mtime = true;
                no-playlist = true; # Download only the video if the link refers to a playlist
                output = "~/Videos/YouTube/%(title)s.%(ext)s";
            };
        };
    }];
}
