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

  fnlfmt = pkgs.fnlfmt.overrideAttrs (old: {
    src = pkgs.fetchFromSourcehut {
      owner = "~technomancy";
      repo = "fnlfmt";
      rev = "main";
      sha256 = "sha256-19JJugN66Xn+5GkMcaVWzCI9b9gH9x63m+hhT8AwYuc=";
    };
    patches = [
      ./patch/0001-Fix-lint-warnings.patch
      # ./patch/0002-Always-use-double-quoted-strings-for-table-values.patch
      ./patch/0003-Respect-manual-line-breaks-in-collections.patch
      ./patch/0004-Run-fnlfmt-on-fnlfmt.patch
      ./patch/0005-Update-documentation-regarding-hex-notation-preserva.patch
      ./patch/0006-Add-support-for-shebang.patch
    ];
  });
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        fennel-wrapped # A lisp that compiles to Lua
        pkgs.fennel-ls # Fennel LSP
        fnlfmt # Formatter for Fennel
      ];
    }
  ];
}
