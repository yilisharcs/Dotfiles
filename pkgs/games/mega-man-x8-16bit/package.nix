{ lib
, fetchurl
, fetchzip
, stdenv
, makeWrapper
, makeDesktopItem
, copyDesktopItems
}:

let
    icon = fetchurl {
        url = "https://sonicfangameshq.com/forums/showcase/mega-man-x8-16-bit.2184/cover-image";
        hash = "sha256-Cgps2qEIan3wbvmbi1qCF4qaigqaR88/I41n4Ub9KHw=";
    };
in

stdenv.mkDerivation (finalAttrs: {
    pname = "mega-man-x8-16bit";
    version = "1.0.0.9";

    src = fetchzip {
        url = "https://sonicfangameshq.com/forums/dl-attach.php?uri=attachments/mega-man-x8-16-bit-1-0-0-9-zip.35187/";
        extension = "zip"; # required because php download returns a misnamed file
        hash = "sha256-x7/2xfsXuPjchkoXG7bVB5hbevnBjkDWsiQSoBDi2Sg=";
    };

    desktopItems = [(makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Mega Man X8 16bit";
        exec = "@out@/bin/${finalAttrs.meta.mainProgram}";
        icon = icon;
        categories = [ "Game" ];
        terminal = false;
    })];

    nativeBuildInputs = [
        copyDesktopItems
        makeWrapper
    ];

    dontBuild = true;
    dontConfigure = true;

    # TODO: try to export files with godot to produce a native linux binary
    installPhase = ''
        mkdir -p $out/share/${finalAttrs.pname}
        cp "Mega Man X8 16-bit 1.0.0.9.exe" $out/share/${finalAttrs.pname}/mega-man-x8-16bit.exe

        mkdir -p $out/bin
        # TODO: make wine a proper dependency
        makeWrapper ${stdenv.shell} $out/bin/${finalAttrs.meta.mainProgram} \
            --add-flags "-c 'exec wine $out/share/${finalAttrs.pname}/mega-man-x8-16bit.exe'"

        runHook postInstall # Needed to insert the desktop file

        substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
            --replace-warn "@out@" "$out"
    '';

    meta = {
        description = "Mega Man X8 16bit";
        homepage = "https://sonicfangameshq.com/forums/showcase/mega-man-x8-16-bit.2184/";
        license = {
            fullName = "Mega Man X8 16-bit License";
            url = "https://raw.githubusercontent.com/AlyssonDaPaz/Mega-Man-X8-16-bit/main/LICENSE.md";
            free = false;
            redistributable = true;
        };
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        mainProgram = "mmx8-16bit";
        platforms = lib.platforms.linux;
    };
})
