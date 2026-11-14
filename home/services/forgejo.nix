{ config, ... }:
let
  quadlet = config.virtualisation.quadlet;
  dataDir = "/home/prod/data";
  dbPassword = "test-only-forgejo-password-change-before-deploy";
  proxyLabels = {
    "traefik.enable" = "true";
    "traefik.docker.network" = "proxy";
  };
in
{
  # These test-only credentials are stored in the Nix store. Replace them with
  # sops-managed secrets before using this configuration beyond VM testing.
  virtualisation.quadlet = {
    enable = true;

    networks.forgejo_internal.networkConfig = {
      name = "forgejo_internal";
      internal = true;
    };

    containers.db = {
      autoStart = true;
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
      };
      containerConfig = {
        image = "docker.io/library/postgres:14";
        networks = [ quadlet.networks.forgejo_internal.ref ];
        environments = {
          POSTGRES_USER = "forgejo";
          POSTGRES_PASSWORD = dbPassword;
          POSTGRES_DB = "forgejo";
        };
        volumes = [ "${dataDir}/postgres:/var/lib/postgresql/data:U" ];
      };
    };

    containers.forgejo = {
      autoStart = true;
      unitConfig = {
        Requires = [ "db.service" ];
        After = [ "db.service" ];
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
      };
      containerConfig = {
        image = "codeberg.org/forgejo/forgejo:16-rootless";
        user = "1000:1000";
        userns = "keep-id:uid=1000,gid=1000";
        networks = [
          quadlet.networks.proxy.ref
          quadlet.networks.forgejo_internal.ref
        ];
        publishPorts = [ "0.0.0.0:2222:2222" ];
        environments = {
          TZ = "Europe/Warsaw";
          USER_UID = "1000";
          USER_GID = "1000";
          FORGEJO__database__DB_TYPE = "postgres";
          FORGEJO__database__HOST = "db:5432";
          FORGEJO__database__NAME = "forgejo";
          FORGEJO__database__USER = "forgejo";
          FORGEJO__database__PASSWD = dbPassword;
          FORGEJO__server__DOMAIN = "forgejo.localhost";
          FORGEJO__server__ROOT_URL = "http://forgejo.localhost:8080/";
          FORGEJO__server__SSH_DOMAIN = "forgejo.localhost";
          FORGEJO__server__SSH_PORT = "2222";
          FORGEJO__server__SSH_LISTEN_PORT = "2222";
          FORGEJO__actions__ENABLED = "true";
        };
        volumes = [ "${dataDir}/forgejo:/var/lib/gitea:Z" ];
        labels = proxyLabels // {
          "traefik.http.routers.forgejo.rule" = "Host(`forgejo.localhost`)";
          "traefik.http.routers.forgejo.entrypoints" = "web";
          "traefik.http.services.forgejo.loadbalancer.server.port" = "3000";
        };
      };
    };
  };
}
