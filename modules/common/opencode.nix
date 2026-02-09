{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # HACK: Impure bc the upstream packages crashes on launch with SIGILL...
        home.packages = [ pkgs.fnm ];
        #           fnm install --latest
        #           npm install -g opencode-ai@1.1.51
        #           opencode auth login
        #       Add fnm-managed binaries to PATH
        home.sessionPath = [
            "$HOME/.local/share/fnm/aliases/default/bin"
        ];

        programs.opencode = enabled {
            settings = {
                autoupdate = false;
                # HACK: https://github.com/jenslys/opencode-gemini-auth/issues/55
                plugin = [ "opencode-gemini-auth@1.4.0" ];
                permission = {
                    external_directory = {
                        "*" = "ask";
                    };
                    bash = {
                        "*" = "ask";

                        "awk *" = "ask";
                        "cp *"  = "ask";
                        "mv *"  = "ask";
                        "rm *"  = "ask";

                        "cat *"     = "allow";
                        "df*"       = "allow";
                        "du*"       = "allow";
                        "fd*"       = "allow";
                        "grep *"    = "allow";
                        "head *"    = "allow";
                        "jq *"      = "allow";
                        "ls*"       = "allow";
                        "objdump *" = "allow";
                        "pwd*"      = "allow";
                        "rg *"      = "allow";
                        "tail *"    = "allow";
                        "xxd *"     = "allow";

                        "find *"         = "allow";
                        "find *-delete*" = "ask";
                        "find *-exec*"   = "ask";

                        "git *"             = "ask";
                        "git clean*"        = "deny";
                        "git commit*"       = "deny";
                        "git push*"         = "deny";
                        "git rebase*"       = "deny";
                        "git reset*"        = "deny";
                        "git restore*"      = "deny";
                        "git check-ignore*" = "allow";
                        "git diff*"         = "allow";
                        "git log*"          = "allow";
                        "git ls-files*"     = "allow";
                        "git show*"         = "allow";
                        "git status*"       = "allow";

                        "sed *"            = "allow";
                        "sed *--in-place*" = "deny";
                        "sed *-i*"         = "deny";

                        "gh *"   = "deny";
                        "sudo *" = "deny";
                    };
                    read = {
                        "*"             = "allow";
                        "~/.gnupg/**"   = "deny";
                        "~/.ssh/**"     = "deny";
                        "~/Shared/**"   = "deny";
                    };
                    edit = {
                        "*"             = "ask";
                        "~/.gnupg/**"   = "deny";
                        "~/.ssh/**"     = "deny";
                        "~/Shared/**"   = "deny";
                    };
                };
            };
        };
    }];
}
