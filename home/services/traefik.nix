{ config, pkgs, ... }:
let
  quadlet = config.virtualisation.quadlet;
in
{
  # Traefik's Docker provider reads Podman's rootless-compatible API socket.
  systemd.user.sockets.podman = {
    Unit.Description = "Podman API socket for rootless containers";
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install.WantedBy = [ "sockets.target" ];
  };

  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API service";
      Requires = [ "podman.socket" ];
      After = [ "podman.socket" ];
    };
    Service = {
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
      Type = "exec";
    };
  };

  virtualisation.quadlet = {
    enable = true;

    networks.proxy.networkConfig = {
      name = "proxy";
    };

    containers.traefik = {
      autoStart = true;
      unitConfig = {
        Requires = [ "podman.socket" ];
        After = [ "podman.socket" ];
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
      };
      containerConfig = {
        image = "docker.io/library/traefik:v3.3";
        networks = [ quadlet.networks.proxy.ref ];
        # Bind on all VM interfaces so QEMU hostfwd can reach this rootless port.
        publishPorts = [ "0.0.0.0:8080:80" "0.0.0.0:8443:443" ];
        volumes = [
          "/run/user/1001/podman/podman.sock:/var/run/docker.sock"
        ];
        # The v3.3 image's entrypoint is the Traefik binary itself. Set it
        # explicitly and pass each option separately so Quadlet does not
        # prepend the image's default `traefik` command to these flags.
        entrypoint = "/traefik";
        exec = [
          "--providers.docker=true"
          "--providers.docker.endpoint=unix:///var/run/docker.sock"
          "--providers.docker.exposedbydefault=false"
          "--providers.docker.network=proxy"
          "--entrypoints.web.address=:80"
          "--entrypoints.websecure.address=:443"
          "--api.dashboard=true"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.docker.network" = "proxy";
          "traefik.http.routers.dashboard.rule" = "Host(`traefik.localhost`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
          "traefik.http.routers.dashboard.entrypoints" = "web";
          "traefik.http.routers.dashboard.service" = "api@internal";
        };
      };
    };
  };
}
