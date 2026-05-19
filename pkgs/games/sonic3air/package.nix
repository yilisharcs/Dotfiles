{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems

# build-time link libraries
, curl
, libGL

# runtime dependencies
, udev
## error dialog boxes
, zenity
## audio backends
, alsa-lib
, libpulseaudio
, pipewire

# X11 extensions SDL dlopens at runtime
, libXcursor
, libXfixes
, libXinerama
, libXi
, libXrandr
, libXScrnSaver
, libXxf86vm
}:

stdenv.mkDerivation (finalAttrs: {
    pname = "sonic3air";
    version = "26.03.28.0";

    src = fetchzip {
        url = "https://github.com/Eukaryot/sonic3air/releases/download/v${finalAttrs.version}-stable/sonic3air_game.tar.gz";
        hash = "sha256-yJAo7Bb54DBieb0HzOP0II95njzBSFdGpv7el/5izUE=";
    };

    nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
        copyDesktopItems
    ];

    buildInputs = [
        stdenv.cc.cc.lib
        curl
        libGL
    ];

    # SDL is statically linked and dlopens libraries at runtime
    runtimeDependencies = [
        alsa-lib
        libpulseaudio
        pipewire
        udev
        libXcursor
        libXfixes
        libXinerama
        libXi
        libXrandr
        libXScrnSaver
        libXxf86vm
    ];

    desktopItems = [(makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Sonic 3 A.I.R.";
        exec = "@out@/bin/${finalAttrs.pname}";
        icon = finalAttrs.pname;
        categories = [ "Game" ];
        terminal = false;
    })];

    dontBuild = true;
    dontConfigure = true;

    # TODO: try to compile from source instead
    installPhase = ''
        mkdir -p $out/share/${finalAttrs.pname}
        cp -r . $out/share/${finalAttrs.pname}/
        rm $out/share/${finalAttrs.pname}/setup_linux.sh

        install -Dm444 data/icon.png $out/share/icons/hicolor/64x64/apps/${finalAttrs.pname}.png

        # Redirection shim because I didn't want to run the build
        mkdir -p $out/lib/${finalAttrs.pname}
        gcc -shared -fPIC -ldl -O2 -std=c11 -DNDEBUG \
            -o $out/lib/${finalAttrs.pname}/xdg-redirect.so ${./xdg-redirect.c}

        mkdir -p $out/bin
        makeWrapper $out/share/${finalAttrs.pname}/sonic3air_linux $out/bin/${finalAttrs.pname} \
            --prefix PATH : ${lib.makeBinPath [ zenity ]}                                       \
            --set LD_PRELOAD "$out/lib/${finalAttrs.pname}/xdg-redirect.so"                     \
            --run "@GEN_CONFIG@"

        runHook postInstall # Needed to insert the desktop file

        # Inject the literal bootstrap logic into the wrapper, bypassing build-time expansion.
        # We don't want any cheeky `/homeless-shelter` getting in the way.
        substituteInPlace $out/bin/${finalAttrs.pname}                             \
            --replace-warn "@GEN_CONFIG@"                                          \
            'dir="''${XDG_CONFIG_HOME:-$HOME/.config}/Sonic3AIR"; mkdir -p "$dir"; \
                [ -f "$dir/config.json" ] || LD_PRELOAD= cp "'$out'/share/${finalAttrs.pname}/config.json" "$dir/config.json"'

        substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
            --replace-warn "@out@" "$out"
    '';

    meta = {
        description = "Sonic 3 A.I.R. - A fan-made widescreen remaster of Sonic 3 & Knuckles";
        homepage = "https://sonic3air.org/";
        license = lib.licenses.gpl3Only;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        mainProgram = finalAttrs.pname;
        platforms = lib.platforms.linux;
    };
})
