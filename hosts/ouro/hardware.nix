{ config, lib, modulesPath, ... }: let
    inherit (lib) enabled;
in {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.loader = {
        systemd-boot = enabled;
        efi.canTouchEfiVariables = true;
    };

    boot.initrd = {
        availableKernelModules = [
            "ahci"
            "ehci_pci"
            "sd_mod"
            "usb_storage"
            "usbhid"
            "xhci_pci"
        ];
        kernelModules = [
            # Loading the GPU late seems to unset the console font
            "i915"
        ];
    };

    boot.kernelModules = [ "kvm-intel" ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/991c140a-3cc9-4ec9-89c5-61dbf94fd745";
        fsType = "btrfs";
        options = [ "subvol=@" "compress=zstd" ];
    };

    fileSystems."/home" = {
        device = "/dev/disk/by-uuid/991c140a-3cc9-4ec9-89c5-61dbf94fd745";
        fsType = "btrfs";
        options = [ "subvol=@home" "compress=zstd" ];
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/FAB9-D77A";
        fsType = "vfat";
        options = [
            "dmask=0077"
            "fmask=0077"
        ];
    };

    swapDevices = [{
        device = "/dev/disk/by-uuid/15a16141-3572-4cc0-8b17-12d6810f4ef7";
    }];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Disable touchscreen
    services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="880a", ATTR{authorized}="0"
    '';
}
