{
  silverwine = {
    background = "#0a001a";
    foreground = "#cdd6f4";
    black = "#030008";
    red = "#d31834";
    green = "#00af5f";
    yellow = "#ffaf00";
    blue = "#8787ff";
    magenta = "#b348ff";
    cyan = "#00afff";
    lightGrey = "#afafff";
    darkGrey = "#708090";
    lightRed = "#ef7184";
    lightGreen = "#00af5f";
    lightYellow = "#ffff5f";
    lightBlue = "#bcc8f0";
    lightMagenta = "#c87bff";
    lightCyan = "#8cf8f7";
    white = "#cdd6f4";
  };

  toKmsconPalette = let
    hexToRgb = hex: let
      h = builtins.replaceStrings ["#"] [""] hex;
      p = s: (builtins.fromTOML "a = 0x${s}").a;
    in "${toString (p (builtins.substring 0 2 h))},${toString (p (builtins.substring 2 2 h))},${toString (p (builtins.substring 4 2 h))}";
  in
    scheme: {
      palette = "custom";
      palette-background = hexToRgb scheme.background;
      palette-foreground = hexToRgb scheme.foreground;
      palette-black = hexToRgb scheme.black;
      palette-red = hexToRgb scheme.red;
      palette-green = hexToRgb scheme.green;
      palette-yellow = hexToRgb scheme.yellow;
      palette-blue = hexToRgb scheme.blue;
      palette-magenta = hexToRgb scheme.magenta;
      palette-cyan = hexToRgb scheme.cyan;
      palette-light-grey = hexToRgb scheme.lightGrey;
      palette-dark-grey = hexToRgb scheme.darkGrey;
      palette-light-red = hexToRgb scheme.lightRed;
      palette-light-green = hexToRgb scheme.lightGreen;
      palette-light-yellow = hexToRgb scheme.lightYellow;
      palette-light-blue = hexToRgb scheme.lightBlue;
      palette-light-magenta = hexToRgb scheme.lightMagenta;
      palette-light-cyan = hexToRgb scheme.lightCyan;
      palette-white = hexToRgb scheme.white;
    };

  toGhosttyPalette = scheme: [
    "0=${scheme.black}"
    "1=${scheme.red}"
    "2=${scheme.green}"
    "3=${scheme.yellow}"
    "4=${scheme.blue}"
    "5=${scheme.magenta}"
    "6=${scheme.cyan}"
    "7=${scheme.lightGrey}"
    "8=${scheme.darkGrey}"
    "9=${scheme.lightRed}"
    "10=${scheme.lightGreen}"
    "11=${scheme.lightYellow}"
    "12=${scheme.lightBlue}"
    "13=${scheme.lightMagenta}"
    "14=${scheme.lightCyan}"
    "15=${scheme.white}"
  ];
}
