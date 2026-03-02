{ fetchzip, stdenv }:

stdenv.mkDerivation {
    pname = "fightcade-plugin-fc2json";
    version = "11.0";

    src = fetchzip {
        url = "https://fightcade.download/fc2json.zip";
        hash = "sha256-J6y7n/LTZ/QseFrnJOJp1ExXD5RdDXuXHkovgCyFpeY=";
        stripRoot = false;
    };

    installPhase = ''
        mkdir -p $out/emulator
        cp -r * $out/emulator/
    '';

    dontBuild = true;
    dontConfigure = true;
}
