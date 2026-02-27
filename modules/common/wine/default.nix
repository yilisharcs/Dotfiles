{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            # pkgs.firejail                   # Namespace-based sandboxing tool for Linux
            pkgs.winetricks                 # Easy way to work around problems in Wine
            ## NOTE: stable, full, wayland, waylandFull
            # -- (DEPS: Fightcade, Sonic Mania, etc) Windows compatibility layer
            pkgs.wineWow64Packages.stable   # Support for both 32-bit and 64-bit Windows applications
        ];
    }];
}
