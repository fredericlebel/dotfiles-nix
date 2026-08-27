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

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Chemin vers un fichier d'environnement (ex: géré par SOPS) pour les secrets (comme FORGEJO__database__PASSWD).";
    };
  };

  config = lib.mkIf cfg.enable {
    my.features.infrastructure.caddy.enable = true;
    my.features.infrastructure.postgresql.databases = [ "forgejo" ];

    services.caddy.virtualHosts."${internalDomain}" = {
      extraConfig = myLib.caddy.mkTailscaleHost {
        inherit (cfg) subdomain;
        port = 3000;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo 0755 1000 1000 -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.forgejo = {
        image = "codeberg.org/forgejo/forgejo:9";
        extraOptions = [ "--network=host" ];
        environment = {
          USER_UID = "1000";
          USER_GID = "1000";
          FORGEJO__database__DB_TYPE = "postgres";
          FORGEJO__database__HOST = "127.0.0.1:5432";
          FORGEJO__database__NAME = "forgejo";
          FORGEJO__database__USER = "forgejo";
        };
        environmentFiles = lib.mkIf (cfg.envFile != null) [ cfg.envFile ];
        volumes = [
          "/var/lib/forgejo:/data"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
