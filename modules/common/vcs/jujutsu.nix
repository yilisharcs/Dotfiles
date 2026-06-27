{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe keys;

  jj-help-k = pkgs.writeShellScriptBin "jjk" ''
    ${getExe pkgs.jujutsu} help -k "$1" | ${getExe pkgs.bat} --plain --language markdown
  '';
in {
  home-manager.sharedModules = [
    {
      programs.difftastic.jujutsu = enabled;

      programs.mergiraf = enabled {
        enableGitIntegration = true;
        enableJujutsuIntegration = false;
      };

      programs.jjui = enabled {
        settings = {
          ui.colors.selected = {
            bg = "#1e1829";
            fg = "#8cf8f7";
            bold = true;
          };
        };
      };

      home.packages = [
        jj-help-k
        # pkgs.radicle-node
      ];

      # git-compatible modern version control system
      programs.jujutsu = enabled {
        settings = {
          user = {
            name = "yilisharcs";
            email = "yilisharcs@gmail.com";
          };
          ui = {
            default-command = ["ls"];
            diff-editor = ":builtin";
            conflict-marker-style = "snapshot";
            merge-editor = ":builtin";
          };
          git = {
            colocate = true;
            fetch = ["origin" "upstream"]; # "rad"];
            push = "origin";
            private-commits = "description('wip:*') | description('private:*')";
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = keys.ssh.id;
            sign-on-push = true;
          };
          # shamelessly taken from HSVSphere
          remotes."*" = {
            auto-track-bookmarks = "glob:*";
            push-new-bookmarks = true;
          };
          templates.draft_commit_description =
            /*
            python
            */
            ''
              concat(
                coalesce(description, "\n"),
                surround(
                  "\nJJ: This commit contains the following changes:\n", "",
                  indent("JJ:     ", diff.stat(72)),
                ),
                "\nJJ: ignore-rest\n",
                diff.git(),
              )
            '';
          aliases = {
            a = ["abandon"];

            c = ["commit"];
            ci = ["commit" "--interactive"];

            clone = ["git" "clone"];

            d = ["diff"];

            e = ["edit"];

            fetch = ["git" "fetch"];

            init = ["git" "init"];

            l = ["log"];
            la = ["log" "--revisions" "::"];
            lh = ["log" "--revisions" "::@"];
            ls = ["log" "--summary"];
            lsa = ["log" "--summary" "--revisions" "::"];
            lsh = ["log" "--summary" "--revisions" "::@"];
            lp = ["log" "--patch"];
            lpa = ["log" "--patch" "--revisions" "::"];
            lph = ["log" "--patch" "--revisions" "::@"];

            push = ["git" "push"];

            n = ["new"];

            r = ["rebase"];

            res = ["resolve"];
            resa = ["resolve-ast"];
            resolve-ast = ["resolve" "--tool" "mergiraf"];

            s = ["squash"];
            si = ["squash" "--interactive"];

            sh = ["show"];

            t = ["tag"];

            tug = ["tug-bookmark-here"];
            tug-bookmark-here = ["bookmark" "move" "--from" "closest(@-)" "--to" "closest_pushable(@)"];

            u = ["undo"];
            ui = ["util" "exec" "--" "jjui"];
          };
          # aliases to support tug logic
          revset-aliases."closest(to)" = "heads(::to & bookmarks())";
          revset-aliases."closest_pushable(to)" = "heads(::to & ~description(exact:\"\") & (~empty() | merges()))";
          revsets.log = "present(@) | present(trunk()) | ancestors(remote_bookmarks().. | @.., 4)";
        };
      };
    }
  ];
}
