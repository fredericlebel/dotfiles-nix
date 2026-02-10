{
  config,
  lib,
  myLib,
  myMeta,
  pkgs,
  ...
}:
let
  cfg = config.my.features.vaultwarden;
  internalDomain = "${cfg.subdomain}.${myMeta.connectivity.tailnet}";
in
{
  options.my.features.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = myMeta.subdomain;
      description = "Le sous-domaine utilisé pour l'identité réseau (Tailscale).";
    };

    resticEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Activer les sauvegardes automatisées vers S3 via Restic.";
    };
  };

  config = lib.mkIf cfg.enable {
    my.features.caddy.enable = true;

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        port = config.services.vaultwarden.config.ROCKET_PORT;
      };
    };

    services = {
      vaultwarden = {
        enable = true;
        dbBackend = "postgresql";
        environmentFile = config.sops.secrets."vaultwarden-env".path;

        config = {
          DOMAIN = "https://${internalDomain}/";
          SIGNUPS_ALLOWED = false;
          SHOW_PASSWORD_HINT = false;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          ROCKET_LOG = "critical";
          ORG_EVENTS_ENABLED = true;
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

      restic.backups.vaultwarden =
        let
          pgBackupPath = "${config.services.postgresqlBackup.location}/vaultwarden.sql.gz";
        in
        lib.mkIf cfg.resticEnable {
          environmentFile = config.sops.secrets."restic-vaultwarden-env".path;
          passwordFile = config.sops.secrets."restic-vaultwarden-password".path;
          repository = "s3:${myMeta.s3Endpoint}/${myMeta.s3Bucket}/vaultwarden";

          paths = [
            "/var/lib/vaultwarden"
            pgBackupPath
          ];

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
