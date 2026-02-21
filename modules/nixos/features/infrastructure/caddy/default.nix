{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.caddy;

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
  options.my.features.caddy = {
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
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
        ];
        hash = "sha256-OydhzUGG3SUNeGXAsB9nqXtnwvD36+2p3QzDtU4YyFg=";
      };

      environmentFile = cfg.tailscaleAuthFile;
    };

    systemd.tmpfiles.rules = [
      "d /var/log/caddy 0750 caddy caddy -"
    ];

    systemd.services.tailscaled.environment.TS_PERMIT_CERT_UID = "caddy";

    users.groups.tsusers = { };
    systemd.services.caddy.serviceConfig.SupplementaryGroups = [ "tsusers" ];

    systemd.services.caddy = {
      reloadTriggers = [ ];
      serviceConfig.ExecReload = lib.mkForce "";
    };
  };
}
