{ pkgs, ... }: let
    nil = pkgs.nil.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
            # NOTE: nil has support for pipe operators, but does not pass them
            #       in the invocation flags, which seemed to be hard-coded
            ./patch/nil-pipe-operators.patch
        ];
    });
in {
    home-manager.sharedModules = [{
        # Nix language server
        home.packages = [ nil ];
    }];
}
