{
  lib,
  fetchzip,
  stdenv,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
  libGL,
  libpulseaudio,
  SDL2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "blastem";
  version = "0.6.3-pre-ec47c727cd65";

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "BlastEm";
      exec = "blastem";
      categories = ["Game" "Emulator"];
      terminal = false;
    })
  ];

  src = fetchzip {
    url = "https://www.retrodev.com/blastem/nightlies/blastem64-${finalAttrs.version}.tar.gz";
    hash = "sha256-Y3gKQNTdDz6Znn7wc6ijg/3p6JylaapJJV3pJ6fDjy4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libGL
    libpulseaudio
    SDL2
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/blastem $out/bin
    cp -r . $out/share/blastem/
    rm -rf $out/share/blastem/lib

    for bin in blastem dis termhelper zdis; do
      ln -s $out/share/blastem/$bin $out/bin/$bin
    done

    wrapProgram $out/bin/blastem \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libpulseaudio]} \
      --set SDL_AUDIODRIVER pulseaudio \
      --set SDL_VIDEODRIVER x11

    runHook postInstall
  '';

  meta = {
    description = "The fast and accurate Genesis emulator";
    homepage = "https://www.retrodev.com/blastem/";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "blastem";
    platforms = lib.platforms.linux;
  };
})
