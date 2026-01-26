{
  config,
  lib,
  myMeta,
  pkgs,
  ...
}: let
  cfg = config.my.services.vaultwarden;
in {
  options.my.services.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";

  domain = lib.mkOption {
    type = lib.types.str;
    default = myMeta.vaultwardenSubdomain;
    description = " Le domaine dynamique de vaultwarden";
  };
  };

  config = lib.mkIf cfg.enable {
    services.logrotate.checkConfig = false;

    services.vaultwarden = {
      enable = true;
      #backupDir = "/var/backup/vaultwarden/";
      environmentFile = config.sops.secrets."vaultwarden-env".path;
      config = {
        DOMAIN = "https://${cfg.domain}/";
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
        ORG_EVENTS_ENABLED = true;
      };
    };
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        };
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = myMeta.adminEmail;
    };
    sops.secrets."vaultwarden-env" = {
      owner = "vaultwarden";
      mode = "0400";
    };
    systemd.services.vaultwarden = {
      after = ["sops-install-secrets.service"];
      wants = ["sops-install-secrets.service"];
    };
  };
}
