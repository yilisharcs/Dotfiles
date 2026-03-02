{ fetchzip, stdenv }:

stdenv.mkDerivation {
    pname = "fightcade-plugin-sf3-training-grouflon";
    version = "0.10-unstable-2022-06-25";

    src = fetchzip {
        url = "https://github.com/Grouflon/3rd_training_lua/archive/73ec4c062108fd3494c4fae6b81a61f9cf518b81.zip";
        hash = "sha256-YOZRPTV0+PTXBsQSMOMBrgBTTKAiWP9zYsl8nsXoe5s=";
    };

    installPhase = ''
        mkdir -p $out/emulator/fbneo
        cp -r . $out/emulator/fbneo/fbneo-training-mode.grouflon/

        # fightcade looks for fbneo-training-mode.lua, not 3rd_training.lua; rename to match
        mv $out/emulator/fbneo/fbneo-training-mode.grouflon/3rd_training.lua \
           $out/emulator/fbneo/fbneo-training-mode.grouflon/fbneo-training-mode.lua
    '';

    dontBuild = true;
    dontConfigure = true;
}
