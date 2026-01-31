{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.observability;
in
{
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      listenAddress = "127.0.0.1";
      port = 9100;
    };

    services.prometheus.exporters.postgres = lib.mkIf cfg.exporters.postgres.enable {
      enable = true;
      user = "postgres";
      dataSourceName = "user=postgres host=/run/postgresql dbname=postgres sslmode=disable";
      listenAddress = "127.0.0.1";
      port = 9187;
    };

    networking.firewall.allowedTCPPorts = [ ];
  };
}
