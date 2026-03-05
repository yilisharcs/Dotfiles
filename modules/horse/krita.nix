{ pkgs, ... }: {
    home-manager.sharedModules = [{
        # Raster graphics editor
        home.packages = [ pkgs.krita ];

        programs.yazi.settings.opener = {
            krita = [{ desc = "Open with Krita"; run = ''krita "$@"''; orphan = true; }];
        };

        yaziPrependOpenRules.image.use = [ "krita" ];
    }];
}
