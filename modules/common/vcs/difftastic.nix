{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Syntax-aware diff
        # bin = `difft`
        programs.difftastic = enabled;
    }];
}
