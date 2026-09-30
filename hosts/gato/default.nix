lib:
lib.nixosSystem' {
  buildTier = "pony"; # is not horse

  module = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) collectNix disabled enabled remove;
  in {
    imports =
      [../common.nix]
      ++ (collectNix ./.
        |> remove ./default.nix);

    networking.hostName = "gato";

    host.touchpad = enabled;
    host.sddm = disabled;
    host.ghostty.fontSize = 17;

    home-manager.users.yilisharcs = {
      home.file.".face.icon".source = ../../avatar/yilisharcs.png;
    };
  };
}
