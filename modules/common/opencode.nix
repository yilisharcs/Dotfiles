{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled filter;

  # SIGILL on Ivy Bridge due to standard Bun targeting x86-64-v3; force bun-baseline binary instead
  bun-baseline = pkgs.bun.overrideAttrs (old: {
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
      hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
    };
  });

  opencode-patched = pkgs.opencode.overrideAttrs (old: {
    nativeBuildInputs =
      [bun-baseline]
      ++ (filter (p: (p.pname or "") != "bun") (old.nativeBuildInputs or []));
  });
in {
  home-manager.sharedModules = [
    {
      # NOTE: don't forget to run `opencode auth login`
      # TODO: auth with agenix
      programs.opencode = enabled {
        package = opencode-patched;
        extraPackages = [
          pkgs.jq # Lightweight JSON processor
        ];
        context = ''
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
          - Documentation: Do not comment what is self-explanatory unless required. Do not remove
            comments if they are not outdated unless required. Well-documented code is a priority.
          - Conduct: Do not offer unsolicited advice or proactive suggestions. Answer only the
            explicit questions asked.
          - Operating Mode Disclosure: Do not mention, acknowledge, foreshadow, disclaim, or
            allude to current operating modes, session constraints, or system-provided reminders
            (including "Plan Mode", "Read-Only phase", tool restrictions, or any future
            equivalent) in any part of the response. No prefaces, no footnotes, no parentheticals,
            no "quick notes". A response either discusses the user's topic or it does not exist.
          - Tool Usage: Prefer native grep/glob tools over shell. Never invoke find; use fd or
            native glob. Never pass recursive flags (-r, -R, --recursive) to grep; use the native
            tool's include filter, ripgrep, or explicit paths instead.
          - Version Control: Prefer jujutsu (jj) over git. Use `jj status`, `jj log`, `jj show`,
            `jj diff` instead of their git equivalents. Always pass `--git` to `jj diff` to get
            standard diff output (the default uses difftastic, which is not agent-friendly).
        '';
        settings = {
          autoupdate = false;
          model = "opencode-go/deepseek-v4-flash";
          small_model = "opencode-go/deepseek-v4-flash";
          agent = {
            # built-in subagents
            general = {
              model = "opencode-go/deepseek-v4-flash";
            };
            explore = {
              model = "opencode-go/deepseek-v4-flash";
            };
          };
          permission = {
            external_directory = {
              "*" = "ask";
              "/nix/store/*" = "allow";
            };
            bash = {
              "*" = "ask";

              # I HATE HEREDOCS. HATE. HATE. HATE. HATE.
              # WHOEVER INVENTED THIS, DISHONOR ON YOU!!
              "*<<EOF*" = "deny";
              "*<< *" = "deny";
              "*<<'*" = "deny";
              "*<<\"*" = "deny";
              "*<<-*" = "deny";
              "*<<<*" = "deny";

              "file *" = "allow";
              "which *" = "allow";

              "awk *" = "ask";
              "cp *" = "ask";
              "mv *" = "ask";
              "rm *" = "ask";
              "tee *" = "ask";

              "df*" = "allow"; # report file system space usage
              "du*" = "allow"; # estimate file space usage
              "head *" = "allow";
              "jq *" = "allow"; # CLI JSON processor
              "ls*" = "allow";
              "nm *" = "allow"; # list symbols from object files
              "objdump *" = "allow"; # display information from object files
              "pwd*" = "allow";
              "readelf *" = "allow"; # display information about ELF files
              "sort *" = "allow";
              "tail *" = "allow";
              "uniq *" = "allow";
              "xxd *" = "allow"; # hex and binary dump utility

              "cat *" = "allow";
              # block shell redirection
              "cat > * <<*EOF" = "deny";
              "cat * >*" = "deny";
              "cat * >>*" = "deny";

              "echo *" = "allow";
              # block shell redirection here too
              "echo * >*" = "deny";
              "echo * >>*" = "deny";

              # the slow and fast brothers
              "find *" = "deny";
              "fd*" = "allow";
              "fd *-x*" = "deny";
              "fd *--exec*" = "deny";
              "fd *-X*" = "deny";
              "fd *--exec-batch*" = "deny";
              #
              "rg *" = "allow";
              "grep *" = "allow";
              # deny recursive flags
              "grep * -r *" = "deny";
              "grep -r *" = "deny";
              "grep * -rn *" = "deny";
              "grep -rn *" = "deny";
              "grep * -rl *" = "deny";
              "grep -rl *" = "deny";
              "grep * -ri *" = "deny";
              "grep -ri *" = "deny";
              "grep * -rnw *" = "deny";
              "grep -rnw *" = "deny";

              "gh *" = "ask";
              "gh issue view *" = "allow";

              "git *" = "ask";
              "git add *" = "deny";
              "git checkout *" = "deny";
              "git clean*" = "deny";
              "git commit*" = "deny";
              "git push*" = "deny";
              "git lfs*" = "deny";
              "git rebase*" = "deny";
              "git reset*" = "deny";
              "git restore*" = "deny";
              #
              "git check-ignore*" = "allow";
              "git diff*" = "allow";
              "git log*" = "allow";
              "git ls-files*" = "allow";
              "git merge-tree *" = "allow";
              "git show*" = "allow";
              "git status*" = "allow";

              "jj *" = "ask";
              "jj help*" = "allow";
              "jj * --help*" = "allow";
              "jj * -h*" = "allow";
              "jj abandon*" = "deny";
              "jj absorb*" = "deny";
              "jj arrange*" = "deny";
              "jj commit*" = "deny";
              "jj describe*" = "deny";
              "jj diffedit*" = "deny";
              "jj duplicate*" = "deny";
              "jj fix*" = "deny";
              "jj metaedit*" = "deny";
              "jj new*" = "deny";
              "jj parallelize*" = "deny";
              "jj rebase*" = "deny";
              "jj simplify-parents*" = "deny";
              "jj squash*" = "deny";
              #
              "jj diff*" = "allow";
              "jj evolog*" = "allow";
              "jj interdiff*" = "allow";
              "jj log*" = "allow";
              "jj next*" = "allow";
              "jj prev*" = "allow";
              "jj root*" = "allow";
              "jj show*" = "allow";
              "jj status*" = "allow";
              "jj version*" = "allow";
              # subcommands
              "jj bookmark *" = "ask";
              "jj bookmark list*" = "allow";
              #
              "jj config *" = "ask";
              "jj config get*" = "allow";
              "jj config list*" = "allow";
              "jj config path*" = "allow";
              #
              "jj file *" = "ask";
              "jj file annotate*" = "allow";
              "jj file list*" = "allow";
              "jj file search*" = "allow";
              "jj file show*" = "allow";
              #
              "jj git *" = "ask";
              "jj git remote list*" = "allow";
              #
              "jj op *" = "ask";
              "jj operation *" = "ask";
              "jj op log*" = "allow";
              "jj operation log*" = "allow";
              "jj op show*" = "allow";
              "jj operation show*" = "allow";
              "jj op diff*" = "allow";
              "jj operation diff*" = "allow";
              #
              "jj tag *" = "ask";
              "jj tag list*" = "allow";
              #
              "jj workspace *" = "ask";
              "jj workspace list*" = "allow";
              "jj workspace root*" = "allow";

              "nix eval*" = "deny";
              "nix-env*" = "deny";

              "sed *" = "allow";
              "sed *--in-place*" = "deny";
              "sed *-i*" = "deny";

              "sudo *" = "deny";
            };
            read = {
              "*" = "allow";
              "~/.ssh/**" = "deny";
              "~/Shared/**" = "deny";
            };
            edit = {
              "*" = "ask";
              "~/.ssh/**" = "deny";
              "~/Documents/**" = "deny";
              "~/Downloads/**" = "deny";
              "~/Shared/**" = "deny";
            };
          };
        };
      };
    }
  ];
}
