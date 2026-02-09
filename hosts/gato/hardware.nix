{ config, lib, modulesPath, ... }: let
    inherit (lib) enabled;
in {
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.loader.grub = enabled {
        device = "/dev/sda";
    };

    boot.initrd.availableKernelModules = [
        "ahci"
        "ehci_pci"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "sr_mod"
        "usb_storage"
        "usbhid"
    ];

    boot.kernelModules = [ "kvm-intel" ];
    boot.kernelParams = [
        # Enable this to support brightness controls
        "acpi_backlight=video"
    ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/13678003-881a-434b-9072-1dd10045b7ad";
        fsType = "btrfs";
        options = [ "subvol=@" "compress=zstd" ];
    };

    fileSystems."/home" = {
        device = "/dev/disk/by-uuid/13678003-881a-434b-9072-1dd10045b7ad";
        fsType = "btrfs";
        options = [ "subvol=@home" "compress=zstd" ];
    };

    swapDevices = [{
        device = "/dev/disk/by-uuid/6e44e411-34c3-4c0f-8d62-d2547e33660e";
    }];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
