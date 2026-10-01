lib:
lib.nixosSystem' {
  buildTier = "horse"; # is not pony

  module = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) collectNix enabled remove;
  in {
    imports =
      [../common.nix]
      ++ (collectNix ./.
        |> remove ./default.nix);

    networking.hostName = "doll";

    host.touchpad = enabled;
    host.sddm = enabled;
    host.battery = enabled;
    host.ghostty.fontSize = 19;

    # VM groups
    users.users.yilisharcs.extraGroups = [
      "kvm"
      "libvirtd"
    ];

    home-manager.users.yilisharcs = {
      home.file.".face.icon".source = ../../avatar/yilisharcs.png;
    };
  };
}
