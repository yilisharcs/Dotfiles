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
          ".git/"
          ".jj/"
          ".cache/"
          "Trash/" # .local/share/Trash symlink
          "state/undo/" # Neovim undodir
          "state/backup/" # Neovim backupdir
          "target/" # Rust target dir
          ".zig-cache/" # Zig
        ];
      };
    }
  ];
}
