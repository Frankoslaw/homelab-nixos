# Homelab

## Hardware

I am using smallest instance on contabo. Disclaimer this steps require that you have installed ubuntu 22.04. Other os's could work, but there is no guarantee.

## Deployment:

Set up root ssh key authentication:

```sh
ssh-copy-id root@ip
```

Copy config to `/etc/nixos/configuration.nix`

Install nix os:

```sh
ssh root@ip
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.05 bash -x
```

Install new configuration:

```sh
ssh root@ip
nix-shell -p git doas
git clone https://github.com/Frankoslaw/homelab-nixos.git
doas nixos-rebuild switch --flake .#yourComputer --fast
```

## Projects used

- https://github.com/elitak/nixos-infect/tree/master
