{ lib, ... }: let
    inherit (lib) disabled;
in {
    services.printing = disabled;
}
