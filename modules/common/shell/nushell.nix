{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe getExe';
in {
  home-manager.sharedModules = [
    ({
      config,
      lib,
      ...
    }: let
      inherit (lib.hm.dag) entryAfter;
      inherit (lib.hm.nushell) mkNushellInline;
    in {
      home.activation.symlinkNuHist =
        entryAfter ["writeBoundary"]
        /*
        bash
        */
        ''
          run ln -sf "$HOME/.config/nushell/history.txt" "$HOME/.nu_history"
        '';

      home.activation.nuMutableScratchFile = let
        scratch = "${config.home.homeDirectory}/.local/bin/scratch";
      in
        entryAfter ["writeBoundary"]
        /*
        nu
        */
        ''
          run mkdir -p ${config.home.homeDirectory}/.local/bin
          run touch ${scratch}
          run chmod 755 ${scratch}
          run echo "#!${getExe pkgs.nushell}

          print $\"(ansi yellow_bold)`scratch` is empty.(ansi reset)\"" > ${scratch}
        '';

      # Nushell is an elegant shell for a more civilized age. It doesn't try to be a tab
      # bit better than bash: it treats pipes as pipelines for structured data, it breaks
      # posix. See <https://www.nushell.sh/book/configuration.html> for configuration
      # options. You can also pretty-print and page through the documentation using:
      #     config nu --doc | nu-highlight | less -R
      programs.nushell = enabled {
        plugins = [
          pkgs.nushellPlugins.gstat
          pkgs.nushellPlugins.query
          pkgs.nushellPlugins.semver
        ];
        shellAliases = {
          fg = "job unfreeze";
        };
        environmentVariables = {
          SUDO_PROMPT = mkNushellInline "$'(ansi red_bold)[sudo](ansi reset) password for %u: '";
        };
        # courtesy of HSVSphere
        extraConfig =
          /*
          nu
          */
          ''
            def --wrapped * [program: string = "", ...arguments] {
              if ($program | str contains "#") or ($program | str contains ":") {
                nix run $program -- ...$arguments
              } else {
                nix run ("default#" + $program) -- ...$arguments
              }
            }

            def --wrapped > [...programs] {
              nix shell ...($programs | each {
                if ($in | str contains "#") or ($in | str contains ":") {
                  $in
                } else {
                  "default#" + $in
                }
              } | append "default#bashInteractive") --command bash
            }
          '';
        settings = {
          buffer_editor = "nvim";
          display_errors.termination_signal = false;
          show_banner = false;
          table.mode = "psql";
          use_kitty_protocol = true;
          history = {
            file_format = "plaintext";
            max_size = 10000000;
            sync_on_enter = true;
            isolation = false;
          };
          plugin_gc = {
            default = {
              enabled = true;
              stop_after = mkNushellInline "10sec";
            };
            plugins = {
              gstat.stop_after = mkNushellInline "1min";
            };
          };
          keybindings = [
            {
              name = "job_to_foreground";
              modifier = "control";
              keycode = "char_z";
              mode = ["emacs" "vi_insert" "vi_normal"];
              event = {
                send = "executehostcommand";
                cmd = "job unfreeze";
              };
            }
            {
              name = "fuzzy_history";
              modifier = "control";
              keycode = "char_r";
              mode = ["emacs" "vi_normal" "vi_insert"];
              event = {
                send = "executehostcommand";
                cmd =
                  /*
                  nu
                  */
                  ''
                    commandline edit --replace (
                    history
                    | reverse
                    | group-by command
                    | values
                    | each { $in.0 }
                    | each { $"($in.index + 1)     ($in.command)" }
                    | str join (char -i 0)
                    | fzf
                    --read0
                    --layout reverse
                    --query (commandline)
                    --scheme history
                    --preview-window hidden
                    --bind='ctrl-y:execute-silent(echo -n {2..} | ${getExe' pkgs.wl-clipboard "wl-copy"})+abort'
                    --header 'Press CTRL-Y to copy command into clipboard'
                    | decode utf-8
                    | str trim
                    | str replace -r "^\\d+\\s{5}" "")
                  '';
              };
            }
          ];
        };
      };
    })
  ];
}
