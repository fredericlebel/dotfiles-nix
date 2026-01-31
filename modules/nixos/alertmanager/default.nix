{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.my.services.prometheus.alertmanager;
in
{
  options.my.services.prometheus.alertmanager = {
    enable = lib.mkEnableOption "alertmanager";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.alertmanager = {
      enable = true;
      extraFlags = [ "--cluster.listen-address=" ];

      checkConfig = false;

      environmentFile = config.sops.secrets."prometheus-alertmanager-webhook-url".path;

      configuration = {
        templates = [
          "${pkgs.writeText "discord.tmpl" ''
            {{ define "discord.title" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }}{{ end }}

            {{ define "discord.message" }}
            {{ range .Alerts }}
            **Alert:** {{ .Annotations.summary }}
            **Description:** {{ .Annotations.description }}
            **Severity:** {{ .Labels.severity }}
            ---
            {{ end }}
            {{ end }}
          ''}"
        ];

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
    sops.secrets."prometheus-alertmanager-webhook-url" = { };
  };
}
