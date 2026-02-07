{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.home-assistant;

  hassConfig = pkgs.writeText "configuration.yaml" ''

    # Config de base
    default_config:

    # HTTP est requis pour le reverse proxy ou l'accès direct
    http:
      server_port: 8123
      use_x_forwarded_for: true
      trusted_proxies:
        - 127.0.0.1
        - ::1

    # Infos générales (Hardcodées ou via variables Nix)
    homeassistant:
      name: "Maison Lebel"
      latitude: 46.8138
      longitude: -71.2080
      elevation: 90
      unit_system: metric
      time_zone: "America/Toronto"
      currency: CAD
  '';

in
{
  options.my.features.home-assistant = {
    enable = lib.mkEnableOption "Enable Home Assistant (Containerized)";
  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.backend = "podman";

    systemd.tmpfiles.rules = [
      "d /var/lib/homeassistant 0755 root root -"
    ];

    virtualisation.oci-containers.containers.home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";

      extraOptions = [ "--network=host" ];

      volumes = [
        # Mutable
        "/var/lib/homeassistant:/config"

        # Immutable
        "${hassConfig}:/config/configuration.yaml:ro"
      ];

      environment.TZ = "America/Toronto";
    };

    #networking.firewall.allowedTCPPorts = [ 8123 ];

    environment.systemPackages = [ pkgs.home-assistant-cli ];
  };
}
