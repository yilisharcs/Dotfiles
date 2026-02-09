{ pkgs, ... }: let
    just-patched = pkgs.just.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
            ./patch/yellow.patch
        ];
        doCheck = false;
    });
in {
    home-manager.sharedModules = [{
        home.packages = [ just-patched ];
    }];
}
