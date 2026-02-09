{ lib
, stdenv
, fetchurl
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

{ pname
, version
, src
, description
, desktopName
, ...
}:

let
    # NOTE: missing on 24.02.02.1, but Euka fixed that for 24.12.05.0
    #       Once the new stable is out, we can get rid of this
    icon = fetchurl {
        url = "https://raw.githubusercontent.com/Eukaryot/sonic3air/main/Oxygen/sonic3air/data/images/icon.png";
        sha256 = "09xgl47h9hz3aj1rqkxxx2y0mf201r8j3m71sh9jcmdryhjri7wb";
    };
in

stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

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
        name = pname;
        desktopName = desktopName;
        exec = "@out@/bin/${pname}";
        icon = "sonic3air";
        categories = [ "Game" ];
        terminal = false;
        extraConfig = {
            Encoding = "UTF-8";
        };
    })];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
        mkdir -p $out/share/sonic3air
        cp -r . $out/share/sonic3air/
        rm $out/share/sonic3air/setup_linux.sh

        # Redirection shim because I didn't want to run the build
        mkdir -p $out/lib
        gcc -shared -fPIC -ldl -O2 -std=c11 -DNDEBUG \
            -o $out/lib/xdg-redirect.so ${./xdg-redirect.c}

        mkdir -p $out/bin
        makeWrapper $out/share/sonic3air/sonic3air_linux $out/bin/${pname}  \
            --prefix PATH : ${lib.makeBinPath [ zenity ]}                   \
            --set LD_PRELOAD "$out/lib/xdg-redirect.so"                     \
            --run "@GEN_CONFIG@"

        mkdir -p $out/share/icons/hicolor/64x64/apps
        cp ${icon} $out/share/icons/hicolor/64x64/apps/sonic3air.png

        runHook postInstall # Needed to insert the desktop file

        # Inject the literal bootstrap logic into the wrapper, bypassing build-time expansion.
        # We don't want any cheeky `/homeless-shelter` getting in the way.
        substituteInPlace $out/bin/${pname}                                        \
            --replace-warn "@GEN_CONFIG@"                                          \
            'dir="''${XDG_CONFIG_HOME:-$HOME/.config}/Sonic3AIR"; mkdir -p "$dir"; \
                [ -f "$dir/config.json" ] || LD_PRELOAD= cp "'$out'/share/sonic3air/config.json" "$dir/config.json"'

        substituteInPlace $out/share/applications/${pname}.desktop \
            --replace-warn "@out@" "$out"
    '';

    meta = {
        inherit description;
        homepage = "https://sonic3air.org/";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ ];
        platforms = [ "x86_64-linux" ];
        mainProgram = pname;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
})
