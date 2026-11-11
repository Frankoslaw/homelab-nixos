{ inputs, ... }:
{
  flake = {
    nixosModules.base = import ../modules/nixos/base.nix;
    nixosModules.users = import ../modules/nixos/users.nix;
    nixosModules.cockpit = import ../modules/nixos/cockpit.nix;

    # This intentionally generic configuration is for local VM evaluation and
    # smoke testing. Add hardware and host-specific modules when provisioning.
    nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.default
        ../modules/nixos/base.nix
        ../modules/nixos/users.nix
        ../hosts/vm.nix
      ];
    };
  };
}
