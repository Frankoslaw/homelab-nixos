{ pkgs, ... }:
{
  services.cockpit = {
    enable = true;
    openFirewall = true;
    plugins = with pkgs; [ cockpit-podman cockpit-files ];
    allowed-origins = [
      "http://localhost:9090"
      "http://127.0.0.1:9090"
      "https://127.0.0.1:9090"
    ];
    settings.WebService = {
      AllowUnencrypted = true;
      ProtocolHeader = "X-Forwarded-Proto";
    };
  };

  environment.systemPackages = with pkgs; [
    cockpit
    cockpit-podman
    cockpit-files
  ];
}
