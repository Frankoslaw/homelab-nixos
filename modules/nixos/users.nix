{ ... }:
let
  authorizedKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBF33ot7xAbxecd448QL+WHJvZCR/15GVtktgX0dhXgr frano@DESKTOP-OMN418K";
in
{
  # Keep account passwords and membership in sync with the declared config.
  users.mutableUsers = false;

  users.users.frankoslaw = {
    isNormalUser = true;
    description = "Homelab administrator";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$Homelab2026$k6Izj2qBzLO6vvzjgIDv.Rz.RRPNb2fTvtqV/QzseHB4pGwbFqONl5jj0Ve3OFiwCPrK2PQ0yZewrVwmv8jeF/";
    openssh.authorizedKeys.keys = [ authorizedKey ];
  };

  users.users.root.hashedPassword = "$6$Homelab2026$k6Izj2qBzLO6vvzjgIDv.Rz.RRPNb2fTvtqV/QzseHB4pGwbFqONl5jj0Ve3OFiwCPrK2PQ0yZewrVwmv8jeF/";

  users.users.prod = {
    isNormalUser = true;
    uid = 1001;
    description = "Unprivileged production container account";
    # Keep the user's systemd services and rootless containers running after logout.
    linger = true;
    autoSubUidGidRange = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.frankoslaw = import ../../home/frankoslaw.nix;
    users.prod = import ../../home/prod.nix;
  };
}
