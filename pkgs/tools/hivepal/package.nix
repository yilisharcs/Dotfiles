{
  lib,
  fetchurl,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  icoutils,
  p7zip,
  wineWow64Packages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hivepal";
  version = "2.2";

  src = fetchurl {
    url = "https://github.com/cvghivebrain/HivePal2020/releases/download/v${finalAttrs.version}/HivePal_v${finalAttrs.version}.7z";
    hash = "sha256-xkaD2H/nQ76SxzpCCumDp1v6bvt1xXodsD2r/YKy8oA=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "HivePal";
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
    p7zip
  ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    7z x $src

    mkdir -p $out/share/${finalAttrs.pname}
    cp "HivePal v${finalAttrs.version}.exe" $out/share/${finalAttrs.pname}/${finalAttrs.pname}.exe

    mkdir -p $out/share/doc/${finalAttrs.pname}
    cp README.txt $out/share/doc/${finalAttrs.pname}/

    mkdir -p $out/share/icons/hicolor/32x32/apps
    wrestool -x --type=14 --name=MAINICON "$out/share/${finalAttrs.pname}/${finalAttrs.pname}.exe" \
      > hivepal-group.ico
    icotool -x --width=32 --height=32 hivepal-group.ico \
      -o $out/share/icons/hicolor/32x32/apps/${finalAttrs.pname}.png

    mkdir -p $out/bin
    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/${finalAttrs.pname} \
      --add-flags "$out/share/${finalAttrs.pname}/${finalAttrs.pname}.exe"

    runHook postInstall # Needed to insert the desktop file

    substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
      --replace-warn "@out@" "$out"
  '';

  meta = {
    description = "Sega Mega Drive palette editor";
    homepage = "https://github.com/cvghivebrain/HivePal2020";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = finalAttrs.pname;
    platforms = lib.platforms.linux;
  };
})
