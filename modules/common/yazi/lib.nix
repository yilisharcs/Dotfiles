{ lib, ... }: let
    inherit (lib) mkOption types;
in {
    home-manager.sharedModules = [{
        # `open.prepend_rules` do not merge cleanly; yazi will pick only one of the list.
        # Therefore, a custom option merges that for us, and all is well in the world.
        options.yaziPrependOpenRules = mkOption {
            type = types.attrsOf (types.submodule {
                options = {
                    mime = mkOption { type = types.nullOr types.str; default = null; };
                    name = mkOption { type = types.nullOr types.str; default = null; };
                    use  = mkOption { type = types.listOf types.str; default = [];   };
                };
            });
            default = {};
        };
    }];
}
