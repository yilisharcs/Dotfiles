lib:
lib.nixosSystem' {
  hostRole = "horse"; # is not pony

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

    networking.hostName = "ouro";

    home-manager.users.yilisharcs = {
      home.file.".face.icon".source = ../../avatar/yilisharcs.png;
    };
  };
}
