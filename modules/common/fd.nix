{lib, ...}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    {
      # Better find
      programs.fd = enabled {
        # NEVER. EVER. CHANGE BEHAVIOR IMPLICITLY.
        hidden = false;
        ignores = [
          ".bak/"
          ".cache/"
          ".git/"
          ".jj/"
          "Trash/" # .local/share/Trash symlink
          ".config/BraveSoftware/"
          # neovim
          "state/backup/"
          "state/undo/"
          # js
          ".npm/"
          # nix
          ".direnv/"
          "result/"
          # rust
          "target/"
          # zig
          ".zig-cache/"
        ];
      };
    }
  ];
}
