{ config, lib, pkgs, ... }: let
    inherit (lib) enabled getExe mapAttrsToList;

    ghostty = pkgs.ghostty.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
            ./patch/keyd_1.patch # Consume the...
            ./patch/keyd_2.patch # ... XCOMPOSE file
        ];

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];

        # ghostty complains about missing OpenGL context otherwise
        postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/ghostty                \
                --set MESA_GL_VERSION_OVERRIDE "4.3"    \
                --set MESA_GLSL_VERSION_OVERRIDE "430"
        '';
    });
in {
    home-manager.sharedModules = [{
        xdg.configFile."ghostty/shaders/cursor_warp.glsl".source = ./shaders/cursor_warp.glsl;

        # Neovim doesn't pick ghostty's syntax otherwise sadge
        programs.neovim.plugins = [ ghostty.vim ];

        # Set ghostty as the default terminal for KDE
        programs.plasma.configFile = {
            kdeglobals.General.TerminalApplication = "ghostty --gtk-single-instance=true";
            kdeglobals.General.TerminalService = "com.mitchellh.ghostty.desktop";
        };

        programs.ghostty = enabled {
            package = ghostty;
            installBatSyntax = true;
            installVimSyntax = true;

            themes.silverwine = {
                background = "#0a001a";
                foreground = "#ffdead";
                palette = [
                    "0=#030008"
                    "1=#d31834"
                    "2=#00af5f"
                    "3=#ffaf00"
                    "4=#5f5fff"
                    "5=#b348ff"
                    "6=#00afff"
                    "7=#afafff"
                    "8=#708090"
                    "9=#ef7184"
                    "10=#00af5f"
                    "11=#ffff5f"
                    "12=#8787ff"
                    "13=#c87bff"
                    "14=#8cf8f7"
                    "15=#cdd6f4"
                ];
            };

            settings = {
                theme = "silverwine";
                custom-shader-animation = "always";
                custom-shader = "cursor_warp.glsl";

                copy-on-select = true;
                cursor-style = "block";
                link-url = false; # osc8 popups are annoying
                link-previews = false;
                mouse-hide-while-typing = true;

                command = "${getExe pkgs.nushell}"; # command goes with shell-integration
                # shell-integration = "nushell"; # TODO: enable on v1.3.0
                font-family = "IosevkaTermSlab Nerd Font";
                font-size = if config.networking.hostName == "gato" then 15 else 14;
                font-feature = "-calt,-liga,-dlig"; # disable ligatures

                window-padding-balance = true;
                maximize = true;
                working-directory = "inherit"; # without this, ghostty always starts from $HOME

                keybind = mapAttrsToList (name: value: "${name}=${value}") {
                    f5        = "reload_config";
                    f11       = "toggle_fullscreen";
                    page_up   = "scroll_page_up";
                    page_down = "scroll_page_down";
                } ++ mapAttrsToList (name: value: "ctrl+${name}=${value}") {
                    "0"       = "reset_font_size";
                    f5        = "open_config";
                    equal     = "increase_font_size:1";
                    minus     = "decrease_font_size:1";
                    ","       = "unbind";
                } ++ mapAttrsToList (name: value: "ctrl+shift+${name}=${value}") {
                    period    = "move_tab:1";
                    comma     = "move_tab:-1";
                    n         = "next_tab";
                    p         = "previous_tab";
                    v         = "paste_from_clipboard";
                    t         = "new_tab";
                    w         = "close_tab:this";
                    q         = "quit";
                };
            };
        };
    }];
}
