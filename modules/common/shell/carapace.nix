{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Multishell completion engine
        programs.carapace = enabled;
    }];
}
