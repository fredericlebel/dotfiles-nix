{
  config,
  lib,
  myLib,
  myMeta,
  pkgs,
  ...
}:
let
  cfg = config.my.features.infrastructure.n8n;
  internalDomain = "${cfg.subdomain}.${myMeta.connectivity.tailnet}";
in
{
  options.my.features.infrastructure.n8n = {
    enable = lib.mkEnableOption "Service n8n (Conteneurisé avec Podman, PostgreSQL et Caddy/Tailscale)";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "n8n";
      description = "Le sous-domaine utilisé pour l'identité réseau (Tailscale).";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "2.45.7";
      description = "Version / tag de l'image de conteneur n8n.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5678;
      description = "Port d'écoute local sur l'hôte.";
    };

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Chemin vers le fichier d'environnement SOPS (N8N_ENCRYPTION_KEY, DB_POSTGRESDB_PASSWORD).";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Variables d'environnement supplémentaires passées au conteneur n8n.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Reverse Proxy Caddy / Tailscale
    my.features.infrastructure.caddy.enable = true;

    services.tailscale.enable = true;

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        inherit (cfg) port;
      };
    };

    # 2. Base de données PostgreSQL
    services.postgresql = {
      enable = true;
      package = lib.mkDefault pkgs.postgresql_17;
      ensureDatabases = [ "n8n" ];
      ensureUsers = [
        {
          name = "n8n";
          ensureDBOwnership = true;
        }
      ];
    };

    services.postgresqlBackup = {
      enable = true;
      databases = [ "n8n" ];
    };

    # 3. Synchronisation du mot de passe PostgreSQL depuis le secret SOPS
    systemd.services.n8n-setup-db = lib.mkIf (cfg.envFile != null) {
      description = "Configuration du mot de passe PostgreSQL pour n8n via SOPS";
      after = [
        "postgresql.service"
        "sops-install-secrets.service"
      ];
      wants = [
        "postgresql.service"
        "sops-install-secrets.service"
      ];
      before = [ "podman-n8n.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
      };
      script = ''
        if [ -f "${cfg.envFile}" ]; then
          DB_PASS=$(grep -E '^DB_POSTGRESDB_PASSWORD=' "${cfg.envFile}" | cut -d= -f2- | tr -d '"' | tr -d "'")
          if [ -n "$DB_PASS" ]; then
            ${pkgs.postgresql_17}/bin/psql -c "ALTER USER n8n WITH ENCRYPTED PASSWORD '$DB_PASS';"
          fi
        fi
      '';
    };

    # 4. Permissions répertoires
    systemd.tmpfiles.rules = [
      "d /var/lib/n8n 0750 1000 1000 -"
      "d /var/log/caddy.nix 0755 caddy caddy -"
    ];

    # 5. Conteneur OCI Podman
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers.n8n = {
        image = "docker.io/n8nio/n8n:${cfg.version}";
        extraOptions = [ "--network=host" ];
        volumes = [
          "/var/lib/n8n:/home/node/.n8n"
        ];
        environment = {
          GENERIC_TIMEZONE = "America/Toronto";
          TZ = "America/Toronto";
          N8N_HOST = internalDomain;
          N8N_PORT = toString cfg.port;
          N8N_LISTEN_ADDRESS = "127.0.0.1";
          N8N_PROTOCOL = "https";
          WEBHOOK_URL = "https://${internalDomain}/";
          N8N_METRICS = "true";

          # Configuration PostgreSQL
          DB_TYPE = "postgresdb";
          DB_POSTGRESDB_DATABASE = "n8n";
          DB_POSTGRESDB_USER = "n8n";
          DB_POSTGRESDB_HOST = "127.0.0.1";
          DB_POSTGRESDB_PORT = "5432";
          DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED = "false";
        }
        // cfg.environment;
        environmentFiles = lib.optional (cfg.envFile != null) cfg.envFile;
      };
    };
  };
}
