{ ... }:
{
  imports = [
    ./services/forgejo.nix
    ./services/traefik.nix
  ];

  home = {
    username = "prod";
    homeDirectory = "/home/prod";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
