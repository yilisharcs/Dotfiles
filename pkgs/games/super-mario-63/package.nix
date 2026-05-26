{
  lib,
  fetchurl,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  coreutils,
  wineWow64Packages,
}: let
  icon = fetchurl {
    url = "https://static.wikia.nocookie.net/runouw/images/e/e1/SM63Infobox.png/revision/latest?cb=20141211151353";
    hash = "sha256-81ZUuMEdQbE2UzmpWLiigstU1g8AANrucvSV8cRtxXc=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "super-mario-63";
    version = "2012.05.17";

    src = fetchurl {
      url = "https://runouw.com/downloads/sm63/sm63game.exe";
      hash = "sha256-cFOw1HUYy254l57sYni9N7UiqK9TA9cjW2MVHpBNjZg=";
    };

    desktopItems = [
      (makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Super Mario 63";
        exec = "@out@/bin/${finalAttrs.meta.mainProgram}";
        icon = icon;
        categories = ["Game"];
        terminal = false;
      })
    ];

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
      makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/${finalAttrs.meta.mainProgram} \
          --prefix PATH : ${lib.makeBinPath [coreutils]} \
          --run "@BOOTSTRAP@"

      runHook postInstall # Needed to insert the desktop file

      # NOTE: wherever the game is launched from is the path where the save
      #       files will live. use home-based dir instead of nix store hash
      substituteInPlace $out/bin/${finalAttrs.meta.mainProgram} \
          --replace-warn "@BOOTSTRAP@" \
          'dir="$HOME/Games/${finalAttrs.pname}"; \
           exe="$dir/sm63game.exe"; \
           mkdir -p "$dir"; \
           ln -sf "'$out'/share/${finalAttrs.pname}/sm63game.exe" "$exe"; \
           set -- "$exe" "$@"'

      substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
          --replace-warn "@out@" "$out"
    '';

    meta = {
      description = "Super Mario 63";
      homepage = "https://runouw.com/games/detail/sm63.html";
      sourceProvenance = lib.sourceTypes.binaryNativeCode;
      mainProgram = "sm63";
      platforms = lib.platforms.linux;
    };
  })
