{ config, lib, pkgs, ... }: let
    inherit (lib) literalExpression mkEnableOption mkIf mkOption optional removePrefix unique;
    inherit (lib.hm.dag) entryAfter;

    cfg = config.programs.fightcade;

    fightcadePackage = pkgs.fightcade.override {
        inherit (cfg) dataDir;
        plugins = unique (
            cfg.plugins
            ++ optional cfg.autoDownloadROMs pkgs.fightcade.fc2json
            ++ optional cfg.sf3TrainingMode pkgs.fightcade.sf3-training-grouflon
        );
    };
in {
    options.programs.fightcade = {
        enable = mkEnableOption "Fightcade";

        dataDir = mkOption {
            type = lib.types.str;
            default = "${config.xdg.dataHome}/Fightcade";
            defaultText = literalExpression ''"''${config.xdg.dataHome}/Fightcade"'';
            description = "The absolute path or path relative to the user's home directory where Fightcade will be installed and ROMs will be stored.";
        };

        autoDownloadROMs = mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to automatically download ROMs with fc2json.";
        };

        sf3TrainingMode = mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to replace the generic FBNeo training mode with the specialized SF3 3rd Strike training mode by Grouflon.";
        };

        plugins = mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            example = literalExpression "[ pkgs.fightcade.fc2json ]";
            description = "List of plugins to include in the Fightcade installation.";
        };
    };

    config = mkIf cfg.enable {
        home.packages = [ fightcadePackage ];

        # The user might pass a path with their $HOME; get rid of that.
        home.file."${removePrefix "${config.home.homeDirectory}/" cfg.dataDir}" = {
            source = "${fightcadePackage}/share/fightcade";
            recursive = true;
        };

        home.activation.fightcadeStateLinks = entryAfter ["linkGeneration"] ''
            mkdir -p ${cfg.dataDir}/ROMs
            mkdir -p ${cfg.dataDir}/emulator/fbneo/ROMs   && ln -srnf ${cfg.dataDir}/emulator/fbneo/ROMs   ${cfg.dataDir}/ROMs/"FBNeo ROMs"
            mkdir -p ${cfg.dataDir}/emulator/ggpofba/ROMs && ln -srnf ${cfg.dataDir}/emulator/ggpofba/ROMs ${cfg.dataDir}/ROMs/"FC1 ROMs"
            mkdir -p ${cfg.dataDir}/emulator/flycast/ROMs && ln -srnf ${cfg.dataDir}/emulator/flycast/ROMs ${cfg.dataDir}/ROMs/"Flycast ROMs"
            mkdir -p ${cfg.dataDir}/emulator/snes9x/ROMs  && ln -srnf ${cfg.dataDir}/emulator/snes9x/ROMs  ${cfg.dataDir}/ROMs/"SNES9x ROMs"

            cd ${cfg.dataDir}/emulator/fbneo
            ln -sfn ${if cfg.sf3TrainingMode then "fbneo-training-mode.grouflon" else "fbneo-training-mode.default"} fbneo-training-mode
        '';
    };
}
