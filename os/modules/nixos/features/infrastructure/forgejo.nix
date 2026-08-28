{
  config,
  lib,
  myLib,
  myMeta,
  ...
}:

let
  cfg = config.my.features.infrastructure.forgejo;
  internalDomain = "${cfg.subdomain}.${myMeta.connectivity.tailnet}";
in
{
  options.my.features.infrastructure.forgejo = {
    enable = lib.mkEnableOption "Enable Forgejo (Containerized with Caddy/Tailscale and PostgreSQL)";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "git";
      description = "Le sous-domaine utilisé pour l'identité réseau (Tailscale).";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = "Port SSH utilisé par le serveur intégré de Forgejo.";
    };

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Chemin vers un fichier d'environnement (ex: géré par SOPS) pour les secrets (comme FORGEJO__database__PASSWD).";
    };

    dbPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Chemin vers le fichier contenant le mot de passe de la base de données PostgreSQL (pour l'initialisation).";
    };
  };

  config = lib.mkIf cfg.enable {
    my.features.infrastructure.caddy.enable = true;
    my.features.infrastructure.postgresql.databases = [ "forgejo" ];
    my.features.infrastructure.postgresql.userPasswordFiles = lib.mkIf (cfg.dbPasswordFile != null) {
      forgejo = cfg.dbPasswordFile;
    };

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        port = 3000;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo 0755 1000 1000 -"
    ];

    networking.firewall.allowedTCPPorts = [ cfg.sshPort ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.forgejo = {
        image = "codeberg.org/forgejo/forgejo:15";
        ports = [
          "127.0.0.1:3000:3000"
          "${toString cfg.sshPort}:22"
        ];
        environment = {
          USER_UID = "1000";
          USER_GID = "1000";
          FORGEJO__database__DB_TYPE = "postgres";
          FORGEJO__database__HOST = "${config.networking.hostName}.${myMeta.connectivity.tailnet}:5432";
          FORGEJO__database__NAME = "forgejo";
          FORGEJO__database__USER = "forgejo";
          FORGEJO__server__SSH_PORT = toString cfg.sshPort;
          FORGEJO__server__SSH_DOMAIN = "${config.networking.hostName}.${myMeta.connectivity.tailnet}";
        };
        environmentFiles = lib.mkIf (cfg.envFile != null) [ cfg.envFile ];
        volumes = [
          "/var/lib/forgejo:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
