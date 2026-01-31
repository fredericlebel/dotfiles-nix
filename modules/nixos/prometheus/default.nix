{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.my.services.prometheus;
in
{
  options.my.services.prometheus = {
    enable = lib.mkEnableOption "prometheus";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "alertmanager";
          static_configs = [
            {
              targets = [ "127.0.0.1:9093" ];
              labels = {
                instance = "ix.opval.com";
                host = "ix";
              };
            }
          ];
        }
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels = {
                instance = "ix.opval.com";
                host = "ix";
              };
            }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:9090" ];
              labels = {
                instance = "ix.opval.com";
                host = "ix";
              };
            }
          ];
        }
        {
          job_name = "postgresql";
          static_configs = [
            {
              targets = [ "127.0.0.1:9187" ];
              labels = {
                instance = "ix.opval.com";
                host = "ix";
              };
            }
          ];
        }
      ];

      alertmanagers = [
        {
          static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ];
        }
      ];

      ruleFiles = [
        ./prometheus-rules.yml
        ./node-exporter.yml
        ./postgres-exporter.yml
      ];
    };
  };
}
