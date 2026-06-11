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
        pkgs.lua-language-server
        pkgs.stylua # opinionated Lua code formatter
      ];
    }
  ];
}
