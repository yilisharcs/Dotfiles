{
  description = "yilisharcs' NixOS Config";

  nixConfig = {
    experimental-features = [
      "cgroups"
      "flakes"
      "nix-command"
      "pipe-operators"
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];

    show-trace = true;
    use-cgroups = true;
    use-xdg-base-directories = true;
    warn-dirty = false;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (builtins) readDir;
    inherit (nixpkgs.lib) mapAttrs filterAttrs;

    lib = nixpkgs.lib.extend <| import ./lib inputs;

    hosts.nixosConfigurations =
      readDir ./hosts
      |> filterAttrs (name: type: type == "directory")
      |> mapAttrs (name: type: import ./hosts/${name} lib);
  in
    hosts
    // {
      inherit lib inputs;

      overlays = {
        default = final: prev:
          import ./pkgs {
            pkgs = final;
            lib = prev.lib;
          };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
