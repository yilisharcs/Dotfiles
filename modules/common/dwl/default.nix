{
  hostRole,
  #
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled mkIf;
in {
  config = mkIf (hostRole == "pony") {
    programs.dwl = enabled {
      package = (pkgs.dwl.override {withCustomConfigH = false;})
        .overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ./patch/0001-dwl-config-ghostty-super-key-moyin-background-alt-f4.patch
            ./patch/0002-dwl-tile-oldest-window-stays-master.patch
          ];
        # the clanker says dwl will die if you don't give it a config.h
        postPatch = (old.postPatch or "") + "cp config.def.h config.h";
      });

      extraSessionCommands =
        /*
        bash
        */
        ''
          export GTK_THEME="Adwaita:dark"
          export QT_QPA_PLATFORMTHEME="qt6ct"
        '';
    };
  };
}
