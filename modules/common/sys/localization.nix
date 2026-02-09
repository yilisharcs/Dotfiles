{ lib, ... }: let
    inherit (lib) const genAttrs;
in {
    i18n.defaultLocale = "C.UTF-8";
    i18n.extraLocaleSettings = genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
    ] <| const "pt_BR.UTF-8";
}
