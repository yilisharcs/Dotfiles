{pkgs, ...}: let
  fennel = pkgs.lua55Packages.fennel;

  fennel-wrapped = pkgs.symlinkJoin {
    inherit (fennel) meta version;
    pname = "fennel";
    paths = [fennel];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/fennel
      makeWrapper ${pkgs.rlwrap}/bin/rlwrap $out/bin/fennel \
        --add-flags "${fennel}/bin/fennel"
    '';
  };
  });
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        fennel-wrapped # A lisp that compiles to Lua
        pkgs.fennel-ls # Fennel LSP
        pkgs.fnlfmt # Formatter for Fennel
      ];
    }
  ];
}
