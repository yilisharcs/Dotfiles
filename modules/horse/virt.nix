{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    environment.systemPackages = [ pkgs.virtiofsd ];

    programs.virt-manager = enabled;

    virtualisation = {
        libvirtd = enabled;
        spiceUSBRedirection = enabled;
        vmVariant.virtualisation = {
            memorySize = 8192; # Use 8GB memory
            cores = 3;
        };
    };

    # To enable this (TODO: enable what!) persistently, run this command:
    #     `sudo virsh net-autostart default`

    # TODO: configure virtualization properly... whatever that means
}
