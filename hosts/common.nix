{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) disabled enabled keys;
in {
  nix.settings.experimental-features = [
    "cgroups"
    "flakes"
    "nix-command"
    "pipe-operators"
  ];

  networking.networkmanager = enabled;

  time.timeZone = "America/Bahia";

  services.xserver = disabled;

  users.users.yilisharcs = {
    description = "yilisharcs";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      keys.ssh.pub
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.neovim
  ];

  services.openssh = enabled {
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Before changing this value read the documentation for this option⏎
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).⏎
  system.stateVersion = "25.11";
  home-manager.sharedModules = [
    {home.stateVersion = "25.11";}
  ];
}
