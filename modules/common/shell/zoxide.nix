{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Better cd
        programs.zoxide = enabled;
    }];
}
