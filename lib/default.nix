inputs: self: super: let
    filesystem = import ./filesystem.nix inputs self super;
    system     = import ./system.nix     inputs self super;
    values     = import ./values.nix     inputs self super;
    keys       = import ./keys.nix;
in filesystem // system // values // { inherit keys; }
