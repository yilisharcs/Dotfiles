{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.nil # Nix language server
        pkgs.alejandra # Uncompromising Nix Code Formatter
      ];
    }
  ];
}
