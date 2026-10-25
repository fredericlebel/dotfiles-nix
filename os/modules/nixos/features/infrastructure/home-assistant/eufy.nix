{
  config,
  lib,
  pkgs,
  ...
}:

let
  haCfg = config.my.features.infrastructure.home-assistant;
  cfg = haCfg.eufy;

  eufySdkIntegration = pkgs.fetchFromGitHub {
    owner = "mega-yfue";
    repo = "ha-eufy-sdk";
    rev = cfg.integrationVersion;
    hash = cfg.integrationHash;
  };
in
{
  options.my.features.infrastructure.home-assistant.eufy = {
    enable = lib.mkEnableOption "Intégration des caméras Eufy (ha-eufy-sdk-bridge + custom_component eufy_sdk)";

    bridgeVersion = lib.mkOption {
      type = lib.types.str;
      default = "0.6.0";
      description = "Version / tag de l'image ghcr.io/mega-yfue/ha-eufy-sdk-bridge.";
    };

    integrationVersion = lib.mkOption {
      type = lib.types.str;
      default = "0.6.0";
      description = "Version / tag du dépôt GitHub mega-yfue/ha-eufy-sdk.";
    };

    integrationHash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-LHMk9n8XJ9vdhLJo7t/OHVWbGcMWywPgdTXYyXG0wKA=";
      description = "Hash SRI du dépôt GitHub mega-yfue/ha-eufy-sdk.";
    };

    country = lib.mkOption {
      type = lib.types.str;
      default = "CA";
      description = "Code pays ISO à 2 lettres du compte Eufy (ex: CA, US, FR, DE).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port WebSocket/HTTP du bridge eufy-sdk.";
    };

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Chemin vers le fichier d'environnement SOPS contenant EUFY_EMAIL et EUFY_PASSWORD.";
    };
  };

  config = lib.mkIf (haCfg.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d /var/lib/home-assistant/custom_components 0755 root root -"
      "d /var/lib/eufy-bridge 0750 root root -"
    ];

    virtualisation.oci-containers.containers = {
      home-assistant.volumes = [
        "${eufySdkIntegration}/custom_components/eufy_sdk:/config/custom_components/eufy_sdk:ro"
      ];

      eufy-bridge = {
        image = "ghcr.io/mega-yfue/ha-eufy-sdk-bridge:${cfg.bridgeVersion}";
        environment = {
          TZ = "America/Toronto";
          EUFY_COUNTRY = cfg.country;
          BRIDGE_HOST = "0.0.0.0";
          BRIDGE_PORT = toString cfg.port;
          EUFY_POLL_MS = "600000";
          STREAM_IDLE_MS = "300000";
          RTSP_IDLE_OFF_MS = "300000";
          BRIDGE_PREWARM = "0";
          BRIDGE_EVENT_LOG = "1";
        };
        environmentFiles = lib.mkIf (cfg.envFile != null) [ cfg.envFile ];
        volumes = [
          "/var/lib/eufy-bridge:/app/data"
        ];
      };
    };
  };
}
