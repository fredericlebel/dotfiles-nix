{
  config,
  lib,
  myMeta,
  pkgs,
  ...
}:
let
  cfg = config.my.features.vaultwarden;
  pgBackupPath = "${config.services.postgresqlBackup.location}/vaultwarden.sql.gz";
in
{
  options.my.features.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";

    domain = lib.mkOption {
      type = lib.types.str;
      default = myMeta.vaultwardenSubdomain;
      description = "Le domaine dynamique de vaultwarden";
    };

    resticEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Activer les backups Restic pour Vaultwarden";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      logrotate.checkConfig = false;

      vaultwarden = {
        enable = true;
        dbBackend = "postgresql";
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

      nginx = {
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

      postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
        ensureDatabases = [ "vaultwarden" ];
        ensureUsers = [
          {
            name = "vaultwarden";
            ensureDBOwnership = true;
          }
        ];
      };

      postgresqlBackup = {
        enable = true;
        databases = [ "vaultwarden" ];
        location = "/var/backup/postgresql";
      };

      restic.backups.vaultwarden = lib.mkIf cfg.resticEnable {
        environmentFile = config.sops.secrets."restic-vaultwarden-env".path;
        passwordFile = config.sops.secrets."restic-vaultwarden-password".path;

        repository = "s3:${myMeta.s3Endpoint}/${myMeta.s3Bucket}/vaultwarden";

        paths = [
          "/var/lib/vaultwarden"
          pgBackupPath
        ];

        #backupPrepareCommand = ''
        #  echo "Lancement du dump PostgreSQL..."
        #  ${config.systemd.services."postgresqlBackup-vaultwarden".serviceConfig.ExecStart}
        #'';

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = myMeta.adminEmail;
    };

    sops.secrets = {
      "restic-vaultwarden-env" = { };
      "restic-vaultwarden-password" = { };
      "vaultwarden-env" = {
        owner = "vaultwarden";
        mode = "0400";
      };
    };

    systemd.services.vaultwarden = {
      after = [
        "sops-install-secrets.service"
        "postgresql.service"
      ];
      wants = [
        "sops-install-secrets.service"
        "postgresql.service"
      ];
    };
  };
}
