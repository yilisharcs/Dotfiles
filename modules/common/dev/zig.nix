{
  inputs,
  pkgs,
  ...
}: let
  zigLatest = inputs.nixpkgs-zig.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        zigLatest.zig_0_17 # Zig toolchain
        zigLatest.zls_0_17 # Zig LSP
      ];
    }
  ];
}
