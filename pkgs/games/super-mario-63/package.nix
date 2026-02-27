{ fetchurl
, stdenv
, makeWrapper
, makeDesktopItem
, copyDesktopItems
}:

let
    icon = fetchurl {
        # FIXME: this icon sucks
        url = "https://runouw.com/include/style/images/W_G_63_Preview.png";
        hash = "sha256-BL/PGFNBG/DEjeX7GIk1PlJu/81UAnAPWxpyDeL1uKw=";
    };
in

stdenv.mkDerivation (finalAttrs: {
    pname = "super-mario-63";
    version = "2012.05.17";

    src = fetchurl {
        url = "https://runouw.com/downloads/sm63/sm63game.exe";
        hash = "sha256-cFOw1HUYy254l57sYni9N7UiqK9TA9cjW2MVHpBNjZg=";
    };

    desktopItems = [(makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Super Mario 63";
        exec = "@out@/bin/${finalAttrs.meta.mainProgram}";
        icon = icon;
        categories = [ "Game" ];
        terminal = false;
    })];

    nativeBuildInputs = [
        copyDesktopItems
        makeWrapper
    ];

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
        mkdir -p $out/share/${finalAttrs.pname}
        cp $src $out/share/${finalAttrs.pname}/sm63game.exe

        mkdir -p $out/bin
        makeWrapper ${stdenv.shell} $out/bin/${finalAttrs.meta.mainProgram} \
            --add-flags "-c 'exec wine \"$out/share/${finalAttrs.pname}/sm63game.exe\" \"\$@\"'"

        runHook postInstall # Needed to insert the desktop file

        substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
            --replace-warn "@out@" "$out"
    '';

    meta = {
        # TODO: where should the author key go?
        description = "Super Mario 63";
        homepage = "https://runouw.com/games/detail/sm63.html";
        # license = lib.licenses.gpl3Only; # TODO: what license??
        # maintainers = with lib.maintainers; [ ];
        mainProgram = "sm63";
    };
})
