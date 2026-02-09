{ lib, ... }: let
    inherit (lib) disabled enabled;
in {
    # https://wiki.nixos.org/wiki/Nix-ld
    # TODO: What goes in here again, and what for?
    programs.nix-ld = enabled {
        libraries = [];
    };
}
