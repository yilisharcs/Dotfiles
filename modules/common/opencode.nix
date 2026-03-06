{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # HACK: Impure bc the upstream packages crashes on launch with SIGILL...
        home.packages = [ pkgs.fnm ];
        #           fnm install --latest
        #           npm install -g opencode-ai@1.2.18
        #           opencode auth login
        #       Add fnm-managed binaries to PATH
        home.sessionPath = [
            "$HOME/.local/share/fnm/aliases/default/bin"
        ];

        programs.opencode = enabled {
            package = null; # TODO: wait for v1.2.18
            settings = {
                autoupdate = false;
                plugin = [ "opencode-gemini-auth@latest" ];
                permission = {
                    external_directory = {
                        "*" = "ask";
                        "/nix/store/*" = "allow";
                    };
                    bash = {
                        "*" = "ask";

                        "echo *"  = "allow";
                        "file *"  = "allow";
                        "which *" = "allow";

                        "awk *" = "ask";
                        "cp *"  = "ask";
                        "mv *"  = "ask";
                        "rm *"  = "ask";

                        "cat *"       = "allow";
                        "cat << *EOF" = "deny";

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
                        "sort *"    = "allow";
                        "tail *"    = "allow";
                        "uniq *"    = "allow";
                        "xxd *"     = "allow";

                        "find *"         = "allow";
                        "find *-delete*" = "ask";
                        "find *-exec*"   = "ask";

                        "git *"             = "ask";
                        "git checkout *"    = "deny";
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
                        "git merge-tree *"  = "allow";
                        "git show*"         = "allow";
                        "git status*"       = "allow";

                        "sed *"            = "allow";
                        "sed *--in-place*" = "deny";
                        "sed *-i*"         = "deny";

                        "gh *"          = "deny";
                        "gh issue view" = "allow";

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
