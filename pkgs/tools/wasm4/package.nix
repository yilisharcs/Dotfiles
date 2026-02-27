{ lib
, pkgs
}:

let
    wasm4-unwrapped = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "wasm4-unwrapped";
        version = "2.7.1";

        src = pkgs.fetchzip {
            url = "https://github.com/aduros/wasm4/releases/download/v${finalAttrs.version}/w4-linux.zip";
            hash = "sha256-t8j11soQKaEJWrO7RglRZd/fuxTtaj/WuFPbF6RrSco=";
        };

        dontPatchELF = true;
        dontStrip = true;

        installPhase = ''
            mkdir -p $out/bin
            mv w4 $out/bin/w4
            chmod +x $out/bin/w4
        '';
    });
in

pkgs.buildFHSEnv {
    name = "w4";

    targetPkgs = pkgs: [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
    ];

    runScript = "${wasm4-unwrapped}/bin/w4";

    meta = {
        description = "Build retro games using WebAssembly for a fantasy console";
        homepage = "https://wasm4.org";
        license = lib.licenses.isc;
        # maintainers = with lib.maintainers; [ ];
        mainProgram = "w4";
    };
}
