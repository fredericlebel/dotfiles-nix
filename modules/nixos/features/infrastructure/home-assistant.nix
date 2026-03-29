{
  config,
  lib,
  myLib,
  myMeta,
  pkgs,
  ...
}:

let
  cfg = config.my.features.infrastructure.home-assistant;
  internalDomain = "${cfg.subdomain}.${myMeta.connectivity.tailnet}";
in
{
  options.my.features.infrastructure.home-assistant = {
    enable = lib.mkEnableOption "Enable Home Assistant (Containerized with Caddy/Tailscale)";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = myMeta.subdomain;
      description = "Le sous-domaine utilisé pour l'identité réseau (Tailscale).";
    };
  };

  config = lib.mkIf cfg.enable {

    my.features.infrastructure.caddy.enable = true;

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        port = 8123;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/home-assistant.nix 0755 root root -"
      "d /var/log/caddy.nix 0755 caddy caddy -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [ "--network=host" ];
        volumes = [
          "/var/lib/home-assistant:/config"
        ];
        environment.TZ = "America/Toronto";
      };
    };

    environment.systemPackages = [ pkgs.home-assistant-cli ];
  };
}
