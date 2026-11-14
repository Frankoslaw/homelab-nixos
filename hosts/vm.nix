{ ... }:
{
  imports = [ ../modules/nixos/cockpit.nix ];

  networking.hostName = "homelab-vm";
  networking.firewall.allowedTCPPorts = [ 8080 2222 ];

  # Forward Traefik and Cockpit to workstation loopback; the guest's reported IP
  # is not directly routable from the host.
  virtualisation.vmVariant.virtualisation = {
    memorySize = 6144;
    cores = 2;
    diskSize = 40 * 1024;
    graphics = false;
    forwardPorts = [
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 8080;
        guest.port = 8080;
      }
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 2222;
        guest.port = 2222;
      }
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 9090;
        guest.port = 9090;
      }
    ];
  };

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
