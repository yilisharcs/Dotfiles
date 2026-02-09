{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Better find
        programs.fd = enabled {
            hidden = true;
            ignores = [
                ".git/"
                ".jj/"
                ".cache/"
                "Trash/"      # .local/share/Trash symlink
                "state/undo/" # Neovim undodir
                "target/"     # Rust target dir
                ".zig-cache/" # Zig
            ];
        };
    }];
}
