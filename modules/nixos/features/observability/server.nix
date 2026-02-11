{
  config,
  lib,
  myLib,
  myMeta,
  ...
}:
let
  cfg = config.my.features.observability;

  alertPort = 9093;
  promPort = config.services.prometheus.port;
  nodePort = config.services.prometheus.exporters.node.port;

  myHost = cfg.subdomain;
  myDomain = myMeta.connectivity.tailnet or "local";
  myFqdn = "${myHost}.${myDomain}";
in
{
  config = lib.mkIf (cfg.enable && cfg.role == "server") {
    services = {
      caddy.virtualHosts."${myFqdn}" = {
        extraConfig = myLib.caddy.mkTailscaleHost {
          inherit (cfg) subdomain;
          port = 3000;
        };
      };

      grafana = {
        enable = true;
        settings.server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "localhost";
        };

        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:${toString promPort}";
              isDefault = true;
            }
          ];
        };
      };

      prometheus = {
        enable = true;
        port = 9090;

        retentionTime = "30d";
        globalConfig.scrape_interval = "15s";

        scrapeConfigs = [
          {
            job_name = "alertmanager";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString alertPort}" ];
                labels.instance = myFqdn;
              }
            ];
          }
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString nodePort}" ];
                labels.instance = myFqdn;
              }
            ];
          }
          {
            job_name = "prometheus";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString promPort}" ];
                labels.instance = myFqdn;
              }
            ];
          }
        ]
        ++ lib.optionals config.services.prometheus.exporters.postgres.enable [
          {
            job_name = "postgresql";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}" ];
                labels.instance = myFqdn;
              }
            ];
          }
        ];

        alertmanagers = [
          {
            static_configs = [ { targets = [ "127.0.0.1:${toString alertPort}" ]; } ];
          }
        ];

        ruleFiles = [
          ./rules/prometheus-rules.yml
          ./rules/node-exporter.yml
          ./rules/postgres-exporter.yml
        ];
      };

      prometheus.alertmanager = {
        enable = true;
        port = alertPort;
        extraFlags = [ "--cluster.listen-address=" ];
        checkConfig = false; # Nécessaire pour les variables d'env ($DISCORD_WEBHOOK)
        environmentFile = config.sops.secrets."prometheus-alertmanager-webhook-url".path;

        configuration = {
          templates = [ "${./templates/discord.tmpl}" ];

          route = {
            receiver = "discord-webhook";
            group_by = [ "alertname" ];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "3h";
          };

          receivers = [
            {
              name = "discord-webhook";
              discord_configs = [
                {
                  webhook_url = "$DISCORD_WEBHOOK";
                  send_resolved = true;
                  title = ''{{ template "discord.title" . }}'';
                  message = ''{{ template "discord.message" . }}'';
                }
              ];
            }
          ];
        };
      };
    };

    sops.secrets."prometheus-alertmanager-webhook-url" = { };
  };
}
