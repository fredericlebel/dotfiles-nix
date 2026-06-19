{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.infrastructure.caddy;

  mkTailscaleHost =
    { subdomain, port }:
    ''
      bind tailscale/${subdomain}

      tls {
        get_certificate tailscale
      }

      reverse_proxy localhost:${toString port} {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
      }
    '';
in
{
  options.my.features.infrastructure.caddy = {
    enable = lib.mkEnableOption "Global Caddy instance with Tailscale";
    tailscaleAuthFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to sops-nix secret file containing TS_AUTHKEY";
      default = config.sops.secrets.tailscale-key.path;
    };
  };

  config = lib.mkIf cfg.enable {
    _module.args = {
      myLib = {
        caddy = {
          inherit mkTailscaleHost;
        };
      };
    };

    services.caddy = {
      enable = true;
      globalConfig = ''
        metrics {
          per_host
        }
      '';
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
        ];
        #hash = "sha256-JergBCe1TiZY2yn/trW9e24uwVoUt0UcLzgfQ+ONpJY=";
        #hash = "sha256-Jc+bdPZus6UYszKcwaUkkoaHUek5KVjsp24wYys3AJo=";
        #hash = "sha256-OENfZRkzz1cZfXCidKRA+nSzqGODITDoKShBof5PVq4=";
        hash = "sha256-xaEgfPyOU/QwMhcSuDTJNoER0yd2ePaF3eBnfn9Jl6I=";
      };

      environmentFile = cfg.tailscaleAuthFile;
    };

    systemd.tmpfiles.rules = [
      "d /var/log/caddy.nix 0750 caddy caddy -"
    ];

    systemd.services.tailscaled.environment.TS_PERMIT_CERT_UID = "caddy";

    users.groups.tsusers = { };
    systemd.services.caddy.serviceConfig.SupplementaryGroups = [ "tsusers" ];

    systemd.services.caddy = {
      reloadTriggers = [ ];
    };
  };
}
