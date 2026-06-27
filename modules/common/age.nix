# secrets management
#
# creating a new secret:
#   agenix -e init.age
#   mv init.age <path>
#
# editing an existing secret:
#   agenix -e <path>
#
# adding a new host:
#   # on the new host, add public key to lib/keys.nix
#   ssh-keyscan localhost | grep ed25519
#   # on any existing host
#   agenix -r
{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.services.openssh) hostKeys;
in {
  imports = [inputs.agenix.nixosModules.age];

  environment.systemPackages = [
    pkgs.age # Modern encryption tool with small explicit keys
    inputs.agenix.packages.x86_64-linux.default # Manage secrets with age encryption
  ];

  home-manager.sharedModules = [
    {
      home.shellAliases = let
        isEd25519 = key: key.type == "ed25519";
      in {
        agenix = "sudo agenix --identity ${(builtins.head (builtins.filter isEd25519 hostKeys)).path}";
      };
    }
  ];
}
