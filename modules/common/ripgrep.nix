{lib, ...}: let
  inherit (lib) disabled enabled;
in {
  home-manager.sharedModules = [
    {
      programs = {
        # Harder, better, faster, stronger grep.
        # bin = `rg`
        ripgrep = enabled {
          arguments = [
            # NEVER. EVER. CHANGE BEHAVIOR IMPLICITLY.
            "--no-hidden"
            # enable smart case
            "--smart-case"
            # exclude files/folders
            "--glob=!.bak"
            "--glob=!.cache"
            "--glob=!.git"
            "--glob=!.jj"
            "--glob=!.npm"
            "--glob=!Trash"
            "--glob=!.config/BraveSoftware"
          ];
        };

        # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more.
        # bin = `rga`
        ripgrep-all = disabled {};
      };
    }
  ];
}
