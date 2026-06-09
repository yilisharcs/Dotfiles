{
  lib,
  fetchurl,
  fetchFromGitHub,
  stdenv,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  # godot
  godot3-headless,
  godot3-export-templates,
  # graphics/audio
  alsa-lib,
  libGL,
  libpulseaudio,
  # X11
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxfixes,
  # hardware support
  udev,
}: let
  icon = fetchurl {
    url = "https://sonicfangameshq.com/forums/showcase/mega-man-x8-16-bit.2184/cover-image";
    hash = "sha256-Cgps2qEIan3wbvmbi1qCF4qaigqaR88/I41n4Ub9KHw=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "mega-man-x8-16-bit";
    version = "1.0.0.9";

    src = fetchFromGitHub {
      owner = "AlyssonDaPaz";
      repo = "Mega-Man-X8-16-bit";
      rev = "2c92967888382115113f79f9eccf28744dccf468";
      hash = "sha256-OHjWVfpQoMYgBPsWKr+g9YQ8yFegpFN0i2DbvMWUXGs=";
    };

    patches = [
      ./patch/linux-export-preset.patch
    ];

    nativeBuildInputs = [
      copyDesktopItems
      makeWrapper
      autoPatchelfHook
      godot3-headless
    ];

    buildInputs = [
      alsa-lib
      libGL
      libpulseaudio
      libx11
      libxcursor
      libxext
      libxi
      libxinerama
      libxrandr
      libxrender
      libxfixes
      udev
    ];

    buildPhase = ''
      runHook preBuild

      # create an isolated environment for godot
      export HOME=$TMPDIR
      export XDG_DATA_HOME=$TMPDIR/data
      export XDG_CONFIG_HOME=$TMPDIR/config
      export XDG_CACHE_HOME=$TMPDIR/cache
      mkdir -p $XDG_DATA_HOME $XDG_CONFIG_HOME $XDG_CACHE_HOME

      # trigger a full asset scan. to export, godot must first import.
      # headless shutdown throws memory leak errors, but they don't affect
      # the final output so it's probably safe to suppress them.
      godot3-headless --path . --export "Linux/X11" /dev/null || true
      godot3-headless --path . --export-pack "Linux/X11" megaman-x8.pck

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/${finalAttrs.pname}
      cp megaman-x8.pck $out/share/${finalAttrs.pname}/megaman-x8.pck

      TEMPLATE_DIR="${godot3-export-templates}/share/godot/templates"
      RELEASE_TEMPLATE=$(find $TEMPLATE_DIR -name linux_x11_64_release | head -n 1)
      cp "$RELEASE_TEMPLATE" $out/share/${finalAttrs.pname}/megaman-x8

      mkdir -p $out/bin
      makeWrapper $out/share/${finalAttrs.pname}/megaman-x8 $out/bin/${finalAttrs.meta.mainProgram} \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [alsa-lib libpulseaudio libGL udev]}" \
          --add-flags "--main-pack $out/share/${finalAttrs.pname}/megaman-x8.pck"

      runHook postInstall

      substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
          --replace-warn "@out@" "$out"
    '';

    desktopItems = [
      (makeDesktopItem {
        name = finalAttrs.pname;
        desktopName = "Mega Man X8 16-bit";
        comment = finalAttrs.meta.description;
        exec = "@out@/bin/${finalAttrs.meta.mainProgram}";
        icon = icon;
        categories = ["Game"];
        terminal = false;
      })
    ];

    meta = {
      description = "Fan-made 16-bit remaster of Mega Man X8";
      homepage = "https://sonicfangameshq.com/forums/showcase/mega-man-x8-16-bit.2184/";
      license = {
        fullName = "Mega Man X8 16-bit License";
        url = "https://raw.githubusercontent.com/AlyssonDaPaz/Mega-Man-X8-16-bit/main/LICENSE.md";
        free = false;
        redistributable = true;
      };
      sourceProvenance = [lib.sourceTypes.fromSource];
      mainProgram = "mmx8-16bit";
      platforms = lib.platforms.linux;
    };
  })
