{ lib, pkgs, ... }: let
    inherit (lib) enabled keys;

    git-scripts = pkgs.runCommand "git-scripts" {
        src = ./scripts;
    } ''
        mkdir -p  $out/bin
        cp $src/* $out/bin/
        chmod +x  $out/bin/*
    '';
in {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.git-doc # Additional documentation for Git (DEPS: git)
            pkgs.git-filter-repo # Quickly rewrite git repository history
            git-scripts
        ];

        programs.difftastic.git = enabled;

        # Distributed version control system
        programs.git = enabled {
            hooks.post-checkout = ./hooks/post-checkout;
            ignores = [
                ".env"
                "tags"
            ];
            signing.signByDefault = true;
            settings = {
                user = {
                    name = "yilisharcs";
                    email = "yilisharcs@gmail.com";
                    signingKey = keys.gpgKeyId;
                };
                init.defaultBranch = "main";
                alias = {
                    last    = "log -1 HEAD";
                    logr    = "log --graph --pretty=format:'%C(yellow)%h %Cgreen[%as]%C(bold red)%d %Creset%s %Cblue<%an>%Creset'";
                    st      = "status";
                    unstage = "reset HEAD --";
                    # Difftastic
                    logf    = "log -p --ext-diff";
                    showf   = "show --ext-diff";
                };
                core = {
                    editor = "nvim";
                    quotepath = false;
                    autocrlf = "input";
                };
                color."diff".meta = "yellow";
                diff = {
                    colorMoved = "plain";
                    mnemonicPrefix = true;
                    tool = "nvimdiff";
                };
                difftool.prompt = false;
                merge = {
                    autoStash = true;
                    tool = "nvimdiff";
                };
                pull.rebase = true;
                push.autoSetupRemote = true;
                rebase = {
                    autoSquash = true;
                    autoStash = true;
                };
                rerere.enabled = true;
                remote.pushDefault = "origin";
            };
        };
    }];
}
