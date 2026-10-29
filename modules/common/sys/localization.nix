{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) const genAttrs;
in {
  i18n.defaultLocale = "C.UTF-8";
  i18n.extraLocaleSettings =
    genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      # "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      # "LC_TIME"
    ]
    <| const "pt_BR.UTF-8";

  # trim locales to only-used
  i18n.glibcLocales = pkgs.glibcLocales.override {
    locales = ''
      C.UTF-8/UTF-8
      en_US.UTF-8/UTF-8
      pt_BR.UTF-8/UTF-8
    '';
  };
}
