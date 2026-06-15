{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        # https://github.com/NixOS/nixpkgs/pull/530910
        (pkgs.lua5_5.overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              patchelf --add-rpath "${pkgs.readline}/lib" "$out/bin/lua"
            '';
        }))
        pkgs.lua55Packages.fennel # A lisp that compiles to Lua
        pkgs.fennel-ls # Fennel LSP
        pkgs.fnlfmt # Formatter for Fennel
      ];
    }
  ];
}
