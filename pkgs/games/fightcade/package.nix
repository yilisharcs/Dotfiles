{ lib
, fetchzip
, stdenv
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, buildFHSEnv

# dependencies
, alsa-lib
, at-spi2-atk
, atk
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXScrnSaver
, libXtst
, libdrm
, libgbm
, libxcb
, nspr
, nss
, pango
, systemd

# runtime
, udev
, libxshmfence
, libGL
, wineWow64Packages

# error dialog boxes
, zenity # TODO: check why it says "install wine32bit" twice

# plugins
, plugins ? []
, dataDir ? "~/.local/share/Fightcade"
}:

let
    fhsEnv = buildFHSEnv {
        name = "fightcade-fhs";
        targetPkgs = pkgs: [
            wineWow64Packages.stable
            zenity
        ];
        runScript = "bash";
    };
in

stdenv.mkDerivation (finalAttrs: {
    pname = "fightcade";
    version = "2.1.45";

    src = fetchzip {
        # unversioned; hash may change later
        url = "https://www.fightcade.com/download/linux";
        extension = "tar.gz";
        hash = "sha256-uhCWWikIg5uyZQTcNtj3immhAl5GhWziUhXKQjnbV9s=";
    };

    desktopItems = [
        (makeDesktopItem {
            name = finalAttrs.pname;
            desktopName = "Fightcade";
            exec = "@out@/bin/${finalAttrs.pname}";
            icon = finalAttrs.pname;
            categories = [
                "Game"
                "Emulator"
                "ArcadeGame"
            ];
            terminal = false;
        })
        (makeDesktopItem {
            name = "fcade-quark";
            desktopName = "Fightcade Replay";
            exec = "@out@/bin/fcade-quark %U";
            mimeTypes = [ "x-scheme-handler/fcade" ];
            terminal = false;
        })
    ];

    nativeBuildInputs = [
        copyDesktopItems
        makeWrapper
        autoPatchelfHook
    ];

    buildInputs = [
        stdenv.cc.cc.lib
        alsa-lib
        at-spi2-atk
        atk
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        gtk3
        libX11
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXScrnSaver
        libXtst
        libdrm
        libgbm
        libxcb
        nspr
        nss
        pango
        systemd
        udev
        libxshmfence
        libGL
    ];

    postFixup = ''
        ln -s ${lib.getLib udev}/lib/libudev.so.1 $out/share/${finalAttrs.pname}/fc2-electron/libudev.so.0
    '';

    patches = [
        ./patch/remove-dead-desktop-integration.patch
        ./patch/write-perms.patch
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
        runHook preInstall

        mkdir -p $out/share/${finalAttrs.pname}
        cp -r . $out/share/${finalAttrs.pname}/

        # idk why patch is spitting out this file
        rm -f $out/share/${finalAttrs.pname}/Fightcade2.sh.orig
        # updating is not to be done in the fightcade side
        rm $out/share/${finalAttrs.pname}/fcade-upd $out/share/${finalAttrs.pname}/fcade-upd.sh
        # we make our own desktop file
        rm $out/share/${finalAttrs.pname}/Fightcade.desktop

        # Rename the generic training mode to .default so plugins can safely replace it
        mv $out/share/${finalAttrs.pname}/emulator/fbneo/fbneo-training-mode \
           $out/share/${finalAttrs.pname}/emulator/fbneo/fbneo-training-mode.default

        # Merge plugins
        ${lib.concatMapStringsSep "\n" (plugin: ''
            cp -r ${plugin}/* $out/share/${finalAttrs.pname}/
        '') plugins}

        mkdir -p $out/bin
        makeWrapper ${fhsEnv}/bin/fightcade-fhs $out/bin/${finalAttrs.pname} \
            --add-flags "-c 'exec \"${dataDir}/Fightcade2.sh\" \"\$@\"' _"

        makeWrapper ${fhsEnv}/bin/fightcade-fhs $out/bin/fcade-quark \
            --add-flags "-c 'exec \"${dataDir}/emulator/fcade.sh\" \"\$@\"' _"

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp $out/share/${finalAttrs.pname}/fc2-electron/resources/app/icon.png $out/share/icons/hicolor/256x256/apps/${finalAttrs.pname}.png

        runHook postInstall # Needed to insert the desktop file

        substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
            --replace-warn "@out@" "$out"
        substituteInPlace $out/share/applications/fcade-quark.desktop \
            --replace-warn "@out@" "$out"
    '';

    passthru = import ./plugins { inherit stdenv fetchzip; };

    meta = {
        # TODO: where should the author key go?
        description = "Fightcade";
        homepage = "https://www.fightcade.com";
        # license = lib.licenses.gpl3Only; # TODO: what license??
        # maintainers = with lib.maintainers; [ ];
        mainProgram = "fightcade";
    };
})
