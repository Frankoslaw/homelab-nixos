# NixOS homelab

This repository is the shared, reproducible NixOS configuration for the
homelab. It uses [flake-parts](https://flake.parts/) to organize flake outputs,
NixOS modules for shared configuration, [deploy-rs](https://github.com/serokell/deploy-rs)
for transactional SSH deployments, and [sops-nix](https://github.com/Mic92/sops-nix)
for runtime secret decryption.

## Current layout

- `flake.nix` declares and pins the project inputs.
- `flake/` contains flake-parts output modules.
- `modules/nixos/` contains reusable, host-independent NixOS modules.
- `hosts/vm.nix` is a generic x86_64 VM configuration for initial evaluation.
- `deploy.nodes` is empty until real hosts are defined; the deploy-rs checks
  are already wired into `nix flake check`.

No Raspberry Pi, PC, VPS, or laptop hardware assumptions are present yet.
Add each machine as a host module that imports the shared modules and its
hardware configuration once you are ready to provision it.

## Evaluate and run the VM

```sh
nix flake check
nix build .#nixosConfigurations.vm.config.system.build.toplevel
nixos-rebuild build-vm --flake .#vm
# or
nix build .#nixosConfigurations.vm.config.system.build.vm
./result/bin/run-homelab-vm-vm
```

The last two commands use the standard NixOS QEMU VM build. Run them on a
Linux build machine with QEMU available.

## Secrets

The sops-nix NixOS module is loaded into the VM configuration and the
`sops`, `age`, and `deploy-rs` tools are available in the development shell.
The separate private secrets flake is not connected yet because its repository
URL was not provided. Add that URL as the `secrets` input in `flake.nix`, then
have host modules point `sops.defaultSopsFile` at encrypted files from that
input. Keep decryption keys out of this repository and out of the Nix store.

## Deployments

Define a deploy-rs node under `flake/deploy.nix` for each real machine when its
system configuration and SSH address are known. deploy-rs activates NixOS
profiles with its rollback mechanism; build locally by default, or configure
the node's `remoteBuild` option to build on the target.
