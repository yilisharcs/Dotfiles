{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # Level editor for 16-bit Sonic games
      home.packages = [pkgs.sonlvl];

      # pkgs.formats.ini requires a header; sonlvl screams if it sees a header
      xdg.dataFile."sonlvl/SonLVL.ini".text =
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
    }
  ];
}
