{
  config,
  lib,
  myLib,
  myMeta,
  pkgs,
  ...
}:

let
  cfg = config.my.features.home-assistant;
  internalDomain = "${cfg.subdomain}.${myMeta.connectivity.tailnet}";
  hassConfig = pkgs.writeText "configuration.yaml" ''
    default_config:

    http:
      server_port: 8123
      use_x_forwarded_for: true
      trusted_proxies:
        - 127.0.0.1
        - ::1

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
    enable = lib.mkEnableOption "Enable Home Assistant (Containerized with Caddy/Tailscale)";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = myMeta.subdomain;
      description = "Le sous-domaine utilisé pour l'identité réseau (Tailscale).";
    };
  };

  config = lib.mkIf cfg.enable {

    my.features.caddy.enable = true;

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        port = 8123;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/homeassistant 0755 root root -"
      "d /var/log/caddy 0755 caddy caddy -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [ "--network=host" ];
        volumes = [
          "/var/lib/homeassistant:/config"
          "${hassConfig}:/config/configuration.yaml:ro"
        ];
        environment.TZ = "America/Toronto";
      };
    };

    environment.systemPackages = [ pkgs.home-assistant-cli ];
  };
}
