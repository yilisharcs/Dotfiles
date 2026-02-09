{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;
in {
    home-manager.sharedModules = [{
        # GitHub CLI tool
        programs.gh = enabled {
            # extensions = [];
            hosts."github.com" = {
                user = "yilisharcs";
                git_protocol = "ssh";
            };
            settings = {
                # What protocol to use when performing git operations.
                # Supported values: ssh, https
                git_protocol = "ssh";
                # What editor gh should run when creating issues, pull requests,
                # etc. If blank, will refer to environment.
                editor = "nvim";
                # When to interactively prompt. This is a global config that cannot
                # be overridden by hostname. Supported values: enabled, disabled
                prompt = "enabled";
                ## A pager program to send command output to, e.g. "less". If blank,
                ## will refer to environment. Set the value to "cat" to disable the pager.
                pager = "${getExe pkgs.less}";
                ## Aliases allow you to create nicknames for gh commands
                # aliases = {
                #         co = "pr checkout";
                # };
                ## The path to a unix socket through which send HTTP connections.
                ## If blank, HTTP traffic will be handled by net/http.DefaultTransport.
                # http_unix_socket = "";
                ## What web browser gh should use when opening URLs. If blank, will
                ##refer to environment.
                # browser = "";
            };
        };
    }];
}
