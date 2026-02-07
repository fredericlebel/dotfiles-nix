{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.my.features.tailscale;
  inherit (pkgs.stdenv) isLinux;
in
{
  options.my.features.tailscale = {
    enable = mkEnableOption "Tailscale Mesh VPN";

    isExitNode = mkOption {
      type = types.bool;
      default = false;
      description = "Advertise this node as an exit node";
    };

    authKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the Tailscale auth key file";
    };
  };

  config = mkIf (cfg.enable && isLinux) {
    environment.systemPackages = [ pkgs.tailscale ];

    services.tailscale.enable = true;

    networking = {
      firewall = {
        allowedUDPPorts = [ 41641 ];
        checkReversePath = if cfg.isExitNode then "loose" else "strict";
        trustedInterfaces = [ "tailscale0" ];
      };

      nameservers = [ "100.100.100.100" ];
      search = [ "taila562f9.ts.net" ];
    };
    boot.kernel.sysctl = mkIf cfg.isExitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    systemd.services.tailscale-autoconnect = mkIf (cfg.authKeyFile != null) {
      description = "Automatic connection to Tailscale";
      after = [
        "network-pre.target"
        "tailscaled.service"
      ];
      wants = [
        "network-pre.target"
        "tailscaled.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        sleep 2
        status=$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)
        if [ "$status" = "Running" ]; then
          exit 0
        fi

        ${pkgs.tailscale}/bin/tailscale up -authkey $(cat ${cfg.authKeyFile}) --ssh
      '';
    };
  };
}
