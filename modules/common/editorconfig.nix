{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        editorconfig = enabled {
            settings."*" = {
                charset = "utf-8";
                end_of_line = "lf";
                insert_final_newline = true;
                trim_trailing_whitespace = true;
            };
        };
    }];
}
