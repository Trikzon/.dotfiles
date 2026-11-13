{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/dev-tools.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/greeter.nix
    ../../modules/nixos/hd60s.nix
    ../../modules/nixos/home-manager.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/nix-ld.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/syncthing.nix
    ../../users/dion.nix
    ../../users/work.nix
  ];

  networking.hostName = "explorer";

  # Root is LVM-on-LUKS on the NVMe drive.
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-uuid/91689ae9-892b-4e69-8907-a5d2e4d5eae5";
    preLVM = true;
    allowDiscards = true;
  };
  boot.resumeDevice = "/dev/mapper/vgroot-swap";

  # 26.05's systemd stage 1 gives up on / after 90s, including passphrase time;
  # the release notes recommend this for LVM on LUKS.
  fileSystems."/".options = [ "x-systemd.device-timeout=infinity" ];

  # Load amdgpu in the initrd so plymouth and the LUKS prompt run at native
  # resolution instead of the firmware framebuffer.
  hardware.amdgpu.initrd.enable = true;

  # Lets the Keychron Launcher (WebHID) remap the K17 Max's firmware keymap.
  services.udev.packages = [ pkgs.keychron-udev-rules ];

  # Shared data drive. Everyone in the storage group can read/write. The
  # permissions live on the filesystem itself and were set once by hand:
  #   chgrp -R storage /mnt/storage && chmod -R g+rwX /mnt/storage
  #   find /mnt/storage -type d -exec chmod g+s {} +
  #   setfacl -R -m g:storage:rwX -m d:g:storage:rwX /mnt/storage
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/7119ed62-ffcd-4d3d-9759-535b28119e37";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  users.groups.storage = { };
  users.users.dion.extraGroups = [ "storage" ];
  users.users.work.extraGroups = [ "storage" ];

  # First NixOS release installed on this machine. Never change it; it is not
  # the version you are running. See `man configuration.nix`.
  system.stateVersion = "26.05";
}
