{ lib, pkgs, ... }: let
    inherit (lib) disabled enabled getExe;

    brave-wrapped = pkgs.symlinkJoin {
        name = "brave";
        paths = [ pkgs.brave ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
            rm $out/bin/brave
            makeWrapper ${getExe pkgs.brave} $out/bin/brave  \
            --add-flags "--ozone-platform=x11"               \
            --set GTK_IM_MODULE "xim" # keyd compat

            for desktop in $out/share/applications/*.desktop; do
                sed -i "s|${getExe pkgs.brave}|$out/bin/brave|g" "$desktop"
            done
        '';
    };
in {
    programs.firefox = disabled;

    home-manager.sharedModules = [{
        # Set Brave as the default browser for KDE
        programs.plasma.configFile = {
            kdeglobals.General.BrowserApplication = "brave-browser.desktop";
        };
    }];

    environment.systemPackages = [ brave-wrapped ];
    programs.chromium = enabled {
        extraOpts = {
            AllowDinosaurEasterEgg = false;
            BookmarkBarEnabled     = false;
            BraveNewsDisabled      = true;
            BraveRewardsDisabled   = true;
            BraveWalletDisabled    = true;
            RestoreOnStartup       = 1;
        };
        extensions = [
            "eimadpbcbfnmbkopoojfekhnkhdbieeh"
            "cofdbpoegempjloogbagkncekinflcnj"
            "ghmbeldphafepmbegfdlkpapadhbakde"
            "eninkmbmgkpkcelmohdlgldafpkfpnaf"
            "fakeocdnmmmnokabaiflppclocckihoj"
            "dbepggeogbaibhgnhhndojpepiihcmeb"
            "hnmpcagpplmpfojmgmnngilcnanddlhb"
            "kkmlkkjojmombglmlpbpapmhcaljjkde"
        ];
        extraOpts.ExtensionSettings = {
            "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {                               # Dark reader
                toolbar_pin = "force_pinned";
                file_url_navigation_allowed = true;
            };
            "cofdbpoegempjloogbagkncekinflcnj".toolbar_pin = "default_unpinned"; # DeepL
            "ghmbeldphafepmbegfdlkpapadhbakde".toolbar_pin = "force_pinned";     # Proton Pass
            "eninkmbmgkpkcelmohdlgldafpkfpnaf".toolbar_pin = "default_unpinned"; # Reddit untranslate
            "fakeocdnmmmnokabaiflppclocckihoj".toolbar_pin = "default_unpinned"; # Sprucemarks
            "dbepggeogbaibhgnhhndojpepiihcmeb" = {                               # Vimium
                toolbar_pin = "force_pinned";
                file_url_navigation_allowed = true;
            };
            "hnmpcagpplmpfojmgmnngilcnanddlhb".toolbar_pin = "force_pinned";     # Windscribe
            "kkmlkkjojmombglmlpbpapmhcaljjkde".toolbar_pin = "default_unpinned"; # Zhongwen_Zh_En_Dictionary
        };
    };
}
