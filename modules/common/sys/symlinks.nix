{
    home-manager.sharedModules = [({ lib, ... }: let
        inherit (lib.hm.dag) entryAfter;
    in {
        home.activation.symlinkMisc = entryAfter ["writeBoundary"] ''
            run ln -snf "/run/media/$USER"                "$HOME/Extern-Media"

            run ln -snf "$HOME/.local/share/Trash/files"  "$HOME/Trash"

            run ln -snf "$HOME/Shared/Memes"              "$HOME/Memes"
            run ln -snf "$HOME/Shared/notebook"           "$HOME/notebook"
            run ln -snf "$HOME/Shared/Pictures"           "$HOME/Pictures"
        '';
    })];
}
