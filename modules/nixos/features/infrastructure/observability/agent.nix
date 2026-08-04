{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.infrastructure.observability;
in
{
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "textfile"
      ];
      extraFlags = [ "--collector.textfile.directory=/var/lib/prometheus-node-exporter-textfiles" ];
      listenAddress = cfg.scrapeAddress;
      port = 9100;
    };

    services.prometheus.exporters.postgres = lib.mkIf cfg.exporters.postgres.enable {
      enable = true;
      user = "postgres";
      dataSourceName = "user=postgres host=/run/postgresql dbname=postgres sslmode=disable";
      listenAddress = cfg.scrapeAddress;
      port = 9187;
    };

    systemd.services.prometheus-node-exporter = {
      after = [
        "tailscaled.service"
        "network-online.target"
      ];
      wants = [
        "tailscaled.service"
        "network-online.target"
      ];
      serviceConfig.FreeBind = true;
    };

    systemd.services.prometheus-postgres-exporter = lib.mkIf cfg.exporters.postgres.enable {
      after = [
        "tailscaled.service"
        "network-online.target"
        "postgresql.service"
      ];
      wants = [
        "tailscaled.service"
        "network-online.target"
        "postgresql.service"
      ];
      serviceConfig.FreeBind = true;
    };

    networking.firewall.allowedTCPPorts = [ ];
  };
}
