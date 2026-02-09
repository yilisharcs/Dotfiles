lib: lib.nixosSystem' {
    isHorse = false; # Pony is not Horse.

    module = { config, keys, lib, pkgs, ... }: let
        inherit (lib) collectNix remove;
    in {
        imports = collectNix ./.
            |> remove ./default.nix;

        networking.hostName = "gato";

        home-manager.users.yilisharcs = {
            home.file.".face.icon".source = ../../avatar/yilisharcs.png;
        };
    };
}
