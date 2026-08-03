{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.infrastructure.postgresql;
in
{
  options.my.features.infrastructure.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL database server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_17;
      description = "Package PostgreSQL à utiliser";
    };

    databases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "opentofu" ];
      description = "Liste des bases de données à créer automatiquement (ex: opentofu)";
    };

    enableTailscaleAccess = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Autoriser les connexions PostgreSQL sécurisées depuis le réseau Tailscale (100.64.0.0/10)";
    };

    userPasswordFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Map associant un nom d'utilisateur PostgreSQL au chemin du fichier contenant son mot de passe décrypté via SOPS";
    };

    enableBackup = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Activer la sauvegarde automatique locale de PostgreSQL";
    };

    enableSSL = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Activer le chiffrement SSL/TLS natif sur PostgreSQL avec certificat TLS auto-signé";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      inherit (cfg) package;
      ensureDatabases = cfg.databases;
      ensureUsers = map (db: {
        name = db;
        ensureDBOwnership = true;
      }) cfg.databases;

      enableTCPIP = cfg.enableTailscaleAccess;

      settings = lib.mkIf cfg.enableSSL {
        ssl = "on";
        ssl_cert_file = "/var/lib/postgresql/server.crt";
        ssl_key_file = "/var/lib/postgresql/server.key";
      };

      authentication = lib.mkIf cfg.enableTailscaleAccess (
        lib.mkOverride 10 ''
          # TYPE  DATABASE        USER            ADDRESS                 METHOD
          local   all             all                                     peer
          host    all             all             127.0.0.1/32            scram-sha-256
          host    all             all             ::1/128                 scram-sha-256
          host    all             all             100.64.0.0/10           scram-sha-256
        ''
      );
    };

    systemd.services.postgresql.preStart = lib.mkIf cfg.enableSSL (
      lib.mkAfter ''
        if [ ! -f /var/lib/postgresql/server.key ]; then
          ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout /var/lib/postgresql/server.key \
            -out /var/lib/postgresql/server.crt \
            -subj "/CN=ecaz.taila562f9.ts.net"
          chmod 0600 /var/lib/postgresql/server.key
          chmod 0644 /var/lib/postgresql/server.crt
        fi
      ''
    );

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enableTailscaleAccess [ 5432 ];

    systemd.services.postgresql-user-passwords = lib.mkIf (cfg.userPasswordFiles != { }) {
      description = "Configuration des mots de passe utilisateurs PostgreSQL via SOPS";
      after = [
        "postgresql.service"
        "sops-install-secrets.service"
      ];
      wants = [
        "postgresql.service"
        "sops-install-secrets.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
      };
      script = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (user: passwordFile: ''
          if [ -f "${passwordFile}" ]; then
            PASS=$(cat "${passwordFile}")
            ${cfg.package}/bin/psql -tA -c "ALTER USER ${user} WITH PASSWORD '$PASS';"
          fi
        '') cfg.userPasswordFiles
      );
    };

    services.postgresqlBackup = lib.mkIf cfg.enableBackup {
      enable = true;
      inherit (cfg) databases;
      location = "/var/backup/postgresql";
    };
  };
}
