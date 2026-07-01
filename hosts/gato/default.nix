lib:
lib.nixosSystem' {
  hostRole = "pony"; # is not horse

  module = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) collectNix remove;
  in {
    imports =
      collectNix ./.
      |> remove ./default.nix;

    networking.hostName = "gato";

    home-manager.users.yilisharcs = {
      home.file.".face.icon".source = ../../avatar/yilisharcs.png;
    };
  };
}
