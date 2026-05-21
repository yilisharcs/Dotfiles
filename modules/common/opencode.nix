{ lib, pkgs, ... }: let
    inherit (lib) enabled filter;

    # SIGILL on Ivy Bridge due to standard Bun targeting x86-64-v3; force bun-baseline binary instead
    bun-baseline = pkgs.bun.overrideAttrs (old: {
        src = pkgs.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
            hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
        };
    });

    opencode-patched = pkgs.opencode.overrideAttrs (old: {
        nativeBuildInputs = [ bun-baseline ]
            ++ (filter (p: (p.pname or "") != "bun") (old.nativeBuildInputs or []));
    });
in {
    home-manager.sharedModules = [{
        # NOTE: don't forget to run `opencode auth login`
        programs.opencode = enabled {
            package = opencode-patched;
            extraPackages = [
                pkgs.jq                 # Lightweight JSON processor
            ];
            context = /* markdown */ ''
                Adhere strictly to the following directives:

                - Tone: Maintain a completely objective tone. Zero sycophancy. Never compliment the
                  user, their code, or their ideas.
                - Code Generation: Never write code that solves the user's implementation problem.
                  Never offer or ask to write code.
                - Examples: You may provide isolated code examples that demonstrate specific API
                  mechanisms or directly answer a targeted question, provided they do not solve the
                  user's primary task. Use your judgment to distinguish an instructional example
                  from a problem solution.
                - Explanations: Focus entirely on mechanical implementation details. Do not use
                  analogies.
                - Formatting: Do not use inline comments in code blocks. Place all necessary
                  explanations in the text outside the code blocks.
                - Conduct: Do not offer unsolicited advice or proactive suggestions. Answer only the
                  explicit questions asked.
            '';
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
                        "cat <<*EOF"  = "deny";

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

                        "gh *"          = "deny";
                        "gh issue view" = "allow";

                        "git *"             = "ask";
                        "git checkout *"    = "deny";
                        "git clean*"        = "deny";
                        "git commit*"       = "deny";
                        "git push*"         = "deny";
                        "git lfs*"          = "deny";
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

                        "nix-env*" = "deny";

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
