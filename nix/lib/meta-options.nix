{ lib, ... }:
{
  options.myMeta = {
    connectivity = {
      tailnet = lib.mkOption {
        type = lib.types.str;
        default = "taila562f9.ts.net";
        description = "Nom du réseau Tailscale";
      };
      rootDomain = lib.mkOption {
        type = lib.types.str;
        default = "opval.com";
        description = "Domaine racine de l'infrastructure";
      };
    };
    adminEmail = lib.mkOption {
      type = lib.types.str;
      default = "flebel@opval.com";
      description = "Email de l'administrateur pour les alertes et les certifs";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "opval.com";
      description = "Domaine de base des services";
    };
    # Métadonnées d'hôte
    system = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "L'architecture du système (ex: aarch64-darwin)";
    };
    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Vrai si l'hôte est sur macOS";
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Tags de déploiement (vps, cloud, desktop)";
    };
    subdomain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Sous-domaine spécifique à l'hôte ou au service";
    };
    # S3 / Sauvegardes
    s3Bucket = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Nom du bucket S3 pour les sauvegardes";
    };
    s3Endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Endpoint S3 (ex: s3.amazonaws.com)";
    };
  };
}
