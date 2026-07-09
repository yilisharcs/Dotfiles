{
  lib,
  fetchzip,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  coreutils,
  icoutils,
  wineWow64Packages,
  direnv,
  just,
  blastem,
  replaceVars,
}: let
  buildBridge = replaceVars ./templates/build-bridge.bat {
    direnv = lib.getExe direnv;
    just = lib.getExe just;
  };
  emulatorBridge = replaceVars ./templates/emulator-bridge.bat {
    direnv = lib.getExe direnv;
    blastem = lib.getExe blastem;
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sonlvl";
    version = "750";

    src = fetchzip {
      # MainMemory doesn't tag releases...
      url = "https://mm.reimuhakurei.net/SonLVL/SonLVL.zip";
      stripRoot = false;
      hash = "sha256-tztebnnJ2u1qDH6/oAkDo//v9WtswrsS5Bf0eHdb0kw=";
    };

    desktopItems = [
      (makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "SonLVL";
        comment = finalAttrs.meta.description;
        exec = "@out@/bin/${finalAttrs.pname}";
        icon = finalAttrs.pname;
        categories = ["Graphics" "Development"];
        terminal = false;
      })
    ];

    nativeBuildInputs = [
      copyDesktopItems
      icoutils
      makeWrapper
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/${finalAttrs.pname}
      cp -r * $out/share/${finalAttrs.pname}/

      cp ${buildBridge} $out/share/${finalAttrs.pname}/build-bridge.bat
      cp ${emulatorBridge} $out/share/${finalAttrs.pname}/emulator-bridge.bat

      mkdir -p $out/share/icons/hicolor/128x128/apps
      wrestool -x --type=14 --name=32512 "$out/share/${finalAttrs.pname}/SonLVL.exe" \
        > sonlvl-group.ico
      icotool -x --width=128 --height=128 sonlvl-group.ico \
        -o $out/share/icons/hicolor/128x128/apps/${finalAttrs.pname}.png

      mkdir -p $out/bin
      makeWrapper ${wineWow64Packages.stableFull}/bin/wine $out/bin/${finalAttrs.pname} \
        --prefix PATH : ${lib.makeBinPath [coreutils wineWow64Packages.stableFull]} \
        --run "@BOOTSTRAP@"

      runHook postInstall # Needed to insert the desktop file

      substituteInPlace $out/bin/${finalAttrs.pname} \
        --replace-warn "@BOOTSTRAP@" \
        'dir="$HOME/.local/share/${finalAttrs.pname}"; \
         WINEPREFIX="$dir/.wine"; \
         mkdir -p "$dir"; \
         cp -u "'$out'/share/${finalAttrs.pname}/"*-bridge.bat "$dir/"; \
         if [ ! -f "$dir/SonLVL.exe" ]; then \
           cp -r "'$out'/share/${finalAttrs.pname}/." "$dir/"; \
         fi; \
         [ -L "$dir/SonLVL.ini" ] \
           && cp --remove-destination "$(readlink -f "$dir/SonLVL.ini")" "$dir/SonLVL.ini" \
           && chmod +w "$dir/SonLVL.ini"; \
         if [ ! -d "$dir/.wine" ]; then \
           wine msiexec /i "${wineWow64Packages.stableFull}/share/wine/mono/wine-mono-10.0.0-x86.msi" /quiet; \
           wineserver -w; \
         fi; \
         set -- "$dir/SonLVL.exe" "$@"'

      substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
        --replace-warn "@out@" "$out"
    '';

    meta = {
      description = "Level editor for 16-bit Sonic games";
      homepage = "https://info.sonicretro.org/SonLVL";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = finalAttrs.pname;
      platforms = lib.platforms.linux;
    };
  })
