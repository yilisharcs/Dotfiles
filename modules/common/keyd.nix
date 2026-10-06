{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  environment.variables.XCOMPOSEFILE = "${pkgs.keyd}/share/keyd/keyd.compose";

  # Key remapping daemon for Linux
  environment.systemPackages = [pkgs.keyd]; # NOTE: services.keyd doesn't put keyd in path
  services.keyd = enabled {
    keyboards.default.ids = ["*"];
    keyboards.default.settings = {
      "main" = {
        "`" = "S-`";
        "102nd" = "layer(shift)";
        "ro" = "layer(shift)";
        capslock = "layer(control)";
        compose = "toggle(numswap)";
      };
      "shift:S" = {
        "`" = "`";
        leftshift = "capslock";
        rightshift = "capslock";
      };
      # inverted number row
      "numswap" = {
        "1" = "S-1";
        "2" = "S-2";
        "3" = "S-3";
        "4" = "S-4";
        "5" = "S-5";
        "6" = "S-6";
        "7" = "S-7";
        "8" = "S-8";
        "9" = "S-9";
        "0" = "S-0";
      };
      "numswap+shift" = {
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "5";
        "6" = "6";
        "7" = "7";
        "8" = "8";
        "9" = "9";
        "0" = "0";
      };
      # common terminal experience for GUI apps
      "control:C" = {
        "[" = "esc";
        i = "tab";
        m = "enter";
      };
      "altgr" = {
        # ASCII doesn't need $XCOMPOSEFILE
        "0" = "°";
        d = "%";
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
