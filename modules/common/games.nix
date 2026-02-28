{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.mega-man-x8-16bit
            pkgs.sonic3air
            pkgs.sonic3air-beta
            pkgs.super-mario-63
        ];
    }];
}
