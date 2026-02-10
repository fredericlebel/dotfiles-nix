{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.security.suricata;
in
{
  options.my.features.security.suricata = {
    enable = lib.mkEnableOption "Suricata IDS (Low Memory Profile)";

    interface = lib.mkOption {
      type = lib.types.str;
      example = "ens3";
      description = "L'interface réseau physique à écouter.";
    };

    homeNet = lib.mkOption {
      type = lib.types.str;
      default = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]";
      description = "Les plages IP considérées comme 'internes'.";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      suricata = {
        enable = true;
        package = pkgs.suricata;

        settings = {
          runmode = "workers";
          af-packet = [ { inherit (cfg) interface; } ];

          vars.address-groups = {
            HOME_NET = cfg.homeNet;
            EXTERNAL_NET = "!$HOME_NET";
          };

          detect.profile = "low";
          flow = {
            memcap = "128mb";
            hash-size = 65536;
            prealloc = 10000;
          };

          app-layer.protocols = {
            modbus.enabled = "no";
            dnp3.enabled = "no";
            enip.enabled = "no";
          };

          outputs = [
            {
              eve-log = {
                enabled = true;
                filetype = "regular";
                filename = "eve.json";
                types = [
                  "alert"
                  "http"
                  "dns"
                  "tls"
                  "ssh"
                  "stats"
                ];
              };
            }
          ];

          threshold-file = "/etc/suricata/threshold.config";
        };

        enabledSources = [
          "et/open"
          "oisf/trafficid"
          "sslbl/ja3-fingerprints"
          "ptresearch/attackdetection"
        ];
      };

      logrotate.enable = true;

      logrotate.settings = {
        suricata-eve = {
          files = "/var/log/suricata/eve.json";
          frequency = "daily";
          rotate = 7;
          compress = true;
          delaycompress = true;
          missingok = true;
          notifempty = true;
          su = "suricata suricata";
          postrotate = "systemctl kill -s SIGHUP suricata";
        };
      };
    };

    services.logrotate.checkConfig = false;

    environment.etc."suricata/threshold.config" = {
      mode = "0644";
      text = ''
        # Suppression des faux positifs récurrents
        # suppress gen_id 1, sig_id 2200121
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/log/suricata 0755 suricata suricata - -"
      "d /var/lib/suricata 0750 suricata suricata - -"
      "d /etc/suricata/rules 0755 suricata suricata - -"
    ];
  };
}
