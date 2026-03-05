{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            ## TODO: configuration.nix:programs.firejail
            # pkgs.firejail                   # Namespace-based sandboxing tool for Linux
            pkgs.winetricks                 # Easy way to work around problems in Wine
            pkgs.wineWow64Packages.stable   # Support for both 32-bit and 64-bit Windows applications
        ];

        programs.yazi.settings.opener = {
            wine = [{ desc = "Execute with Wine"; run = ''wine "$@"''; orphan = true; }];
        };
        yaziPrependOpenRules.wine = {
            mime = "application/{microsoft.portable-executable,msi}";
            use = [ "wine" ];
        };
    }];
}
