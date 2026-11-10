{ inputs, ... }:
{
  flake = {
    nixosModules.base = import ../modules/nixos/base.nix;

    # This intentionally generic configuration is for local VM evaluation and
    # smoke testing. Add hardware and host-specific modules when provisioning.
    nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.sops-nix.nixosModules.sops
        ../modules/nixos/base.nix
        ../hosts/vm.nix
      ];
    };
  };
}
