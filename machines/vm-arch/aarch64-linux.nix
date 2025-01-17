{ config, pkgs, ... }: {
  # https://github.com/NixOS/nixpkgs/pull/140587
  # This will be unnecessary in a bit.
  boot.kernelPatches = [{
    name = "efi-initrd-support";
    patch = null;
    extraConfig = ''
        EFI_GENERIC_STUB_INITRD_CMDLINE_LOADER y
    '';
  }];

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.
  disabledModules = [ "virtualisation/vmware-guest.nix" ];
  imports = [
    ../../modules/vmware-guest.nix
  ];

  # Interface is this on M1
  networking.interfaces.ens160.useDHCP = true;

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # This works through our custom module imported above
  virtualisation.vmware.guest.enable = true;

  # Share our host filesystem
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };
}
