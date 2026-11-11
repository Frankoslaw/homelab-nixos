{ ... }:
{
  imports = [ ../modules/nixos/cockpit.nix ];

  networking.hostName = "homelab-vm";

  # build-vm uses user-mode networking. Forward Cockpit to workstation localhost;
  # the guest's reported IP is not directly routable from the host.
  virtualisation.vmVariant.virtualisation.forwardPorts = [
    {
      from = "host";
      host.address = "127.0.0.1";
      host.port = 9090;
      guest.port = 9090;
    }
  ];

  # Generic VM boot configuration; no physical device assumptions.
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enable = true;
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  services.getty.autologinUser = "root";
  system.stateVersion = "26.05";
}
