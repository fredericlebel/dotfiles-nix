{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.my.services.prometheus.exporters.node;
in
{
  options.my.services.prometheus.exporters.node = {
    enable = lib.mkEnableOption "node-exporter";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };

    services.prometheus.exporters.postgres = {
      enable = true;
      user = "postgres";
      dataSourceName = "user=postgres host=/run/postgresql dbname=postgres sslmode=disable";
      listenAddress = "127.0.0.1";
    };
  };
}
