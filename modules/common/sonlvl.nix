{pkgs, ...}: {
  home-manager.sharedModules = [
    ({lib, ...}: let
      inherit (lib.hm.dag) entryAfter;

      # pkgs.formats.ini requires a header; sonlvl screams if it sees a header
      sonlvlIni =
        pkgs.writeText "SonLVL.ini"
        /*
        ini
        */
        ''
          Emulator=Z:\\\\home\\\\yilisharcs\\\\.local\\\\share\\\\sonlvl\\\\emulator-bridge.bat
          MRUList=Z:\\\\home\\\\yilisharcs\\\\Projects\\\\github.com\\\\sonicretro\\\\skdisasm\\\\SonLVL INI Files\\\\SonLVL.ini
          GridColor=Red
          ObjectGridSize=64
          Username=
          BackgroundColor=32, 30, 80, 100
          IncludeObjectsFG=False
          ObjectsAboveHighPlane=True
          ZoomLevel=1/2x
          SwitchChunkBlockMouseButtons=True
          WindowMode=Maximized
        '';
    in {
      # Level editor for 16-bit Sonic games
      home.packages = [pkgs.sonlvl];

      # seed once and touch again never
      home.activation.sonlvlIni =
        entryAfter ["linkGeneration"]
        /*
        bash
        */
        ''
          ini="$HOME/.local/share/sonlvl/SonLVL.ini"
          if [ ! -e "$ini" ]; then
            run mkdir --parents "$(dirname "$ini")"
            run cp ${sonlvlIni} "$ini"
            run chmod u+w "$ini"
          fi
        '';
    })
  ];
}
