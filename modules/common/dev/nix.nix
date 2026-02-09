{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.nil # Nix language server
        ];
    }];
}
