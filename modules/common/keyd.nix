{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    environment.variables.XCOMPOSEFILE = "${pkgs.keyd}/share/keyd/keyd.compose";

    services.keyd = enabled {
        keyboards.default.ids = ["*"];
        keyboards.default.settings = {
            "main" = {
                "`" = "~";
                "102nd" = "leftshift";
                capslock = "layer(control)";
            };
            "shift:S" = {
                "`" = "`";
                leftshift = "capslock";
                rightshift = "capslock";
            };
            # Common terminal experience for GUI apps
            "control:C" = {
                "[" = "esc";
                i = "tab";
                m = "enter";
            };
            "altgr" = {
                # ASCII doesn't need $XCOMPOSEFILE
                d = "|";
                f = "%";
                s = "\\";
                w = "?";

                "]" = "ª";
                "\\" = "º";
                c = "ç";
                m = "—";
                n = "ñ";
                r = "®";
                t = "™";
                "equal" = "§";
                "[" = "oneshot(agudo)";
                ";" = "oneshot(macron)";
                "'" = "oneshot(greve)";

                a = "ã";
                e = "é";
                i = "í";
                o = "õ";
                u = "ú";
            };
            agudo = {
                a = "á";
                e = "é";
                i = "í";
                o = "ó";
                u = "ú";
            };
            macron = {
                a = "ā";
                e = "ē";
                i = "ī";
                o = "ō";
                u = "ū";
            };
            greve = {
                a = "à";
                e = "è";
                i = "ì";
                o = "ò";
                u = "ù";
            };
            "altgr+shift" = {
                a = "â";
                e = "ê";
                o = "ô";
                c = "©";
            };
        };
    };
}
