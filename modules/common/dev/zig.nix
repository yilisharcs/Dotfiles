{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.zig # Zig toolchain
            pkgs.zls # Zig LSP
        ];
    }];
}
