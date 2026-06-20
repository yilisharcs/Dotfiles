{pkgs, ...}: let
  nil = pkgs.nil.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        # nil has support for pipe operators, but does not pass them
        # in the invocation flags, which seemed to be hard-coded
        ./patch/nil-pipe-operators.patch
      ];
  });
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        nil # Nix language server
        pkgs.alejandra # Uncompromising Nix Code Formatter
      ];
    }
  ];
}
