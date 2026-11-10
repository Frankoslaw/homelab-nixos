{ ... }:
{
  networking.hostName = "homelab-vm";

  # Generic VM boot configuration; no physical device assumptions.
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enable = true;
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  services.getty.autologinUser = "root";
  users.users.root.initialHashedPassword = "";

  system.stateVersion = "26.05";
}
