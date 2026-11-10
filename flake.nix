{
  description = "Deterministic NixOS configuration for a homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add your private secrets flake here once its repository URL is known,
    # for example: secrets.url = "git+ssh://git@github.com/USER/nixos-secrets";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./flake/nixos.nix
        ./flake/deploy.nix
      ];

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt;
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [ deploy-rs sops age ];
        };
      };
    };
}
