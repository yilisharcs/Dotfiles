{ lib, pkgs, ... }: let
    inherit (lib) enabled;

    cmus-icon = pkgs.cmus.overrideAttrs (old: {
        # Here we provide a custom icon for the .desktop file below
        postInstall = (old.postInstall or "") + ''
            install -D ${./cmus.png} $out/share/icons/hicolor/128x128/apps/cmus.png
        '';
    });
in {
    home-manager.sharedModules = [{
        # Small, fast and powerful console music player for Linux and *BSD
        programs.cmus = enabled {
            package = cmus-icon;
            extraConfig = ''
                clear
                add ~/Music/
                update-cache -f
            '';
            theme = "spotify";
        };

        xdg.desktopEntries.cmus = {
            name = "Cmus";
            type = "Application";
            comment = "Play and organize your music collection";
            icon = "cmus";
            exec = "cmus";
            terminal = true;
            categories = [
                "AudioVideo"
                "Audio"
                "Player"
            ];
            settings = {
                TryExec = "cmus";
                Keywords = "Music;Player;";
            };
        };
    }];
}
