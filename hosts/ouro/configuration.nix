{ lib, pkgs, ... }: let
    inherit (lib) disabled enabled;
in {
    nix.settings.experimental-features = [
        "cgroups"
        "flakes"
        "nix-command"
        "pipe-operators"
    ];

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager = enabled;

    # Set your time zone.
    time.timeZone = "America/Bahia";

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver = enabled {
        # Configure keymap in X11
        xkb = {
            layout = "us";
            variant = "";
        };
    };

    # Disable touchpad support
    services.libinput = disabled;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.yilisharcs = {
        description = "yilisharcs";
        isNormalUser = true;
        extraGroups = [
            # sudo
            "wheel"
            # virtual machines
            "kvm"
            "libvirtd"
            # internet
            "networkmanager"
        ];
        packages = [
            # Why are these here? They have competing paths apparently...
            pkgs.sonic3air
            pkgs.sonic3air-beta
        ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search nixpkgs wget
    environment.systemPackages = [
        # pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        # pkgs.wget
        pkgs.neovim
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11";
    home-manager.sharedModules = [{
        home.stateVersion = "25.11";
    }];
}
