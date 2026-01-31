{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.my.services.suricata;
in
{
  options.my.services.suricata = {
    enable = mkEnableOption "Activer Suricata IDS";

    interface = mkOption {
      type = types.str;
      default = "eth0";
      description = "L'interface réseau à écouter.";
    };

    homeNet = mkOption {
      type = types.str;
      default = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]";
      description = "Les plages IP considérées comme 'internes' pour les alertes.";
    };
  };

  config = mkIf cfg.enable {
    services.suricata = {
      enable = true;
      package = pkgs.suricata;

      settings = {
        af-packet = [
          {
            interface = cfg.interface;
          }
        ];

        threshold-file = "/etc/suricata/threshold.config";

        vars = {
          address-groups = {
            HOME_NET = cfg.homeNet;
            EXTERNAL_NET = "!$HOME_NET";
          };
        };

        app-layer = {
          protocols = {
            modbus = {
              enabled = "no";
            };
            dnp3 = {
              enabled = "no";
            };
            enip = {
              enabled = "no";
            };
          };
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

        threading = {
          set-cpu-affinity = true;
          #detect-thread-ratio = cfg.performance.threads;
        };

        detect = {
          profile = "low";
        };

        runmode = "workers";

        flow = {
          memcap = "128mb"; # Force une limite mémoire stricte
          hash-size = 65536; # Réduit la taille de la table de hachage
          prealloc = 10000; # Pré-allocation modeste
        };
      };

      enabledSources = [
        "et/open"
        "oisf/trafficid"
        "sslbl/ja3-fingerprints"
        "tgreen/hunting"
        "ptresearch/attackdetection"
      ];
    };

    environment.etc."suricata/threshold.config" = {
      mode = "0644";
      text = ''
        # Suricata threshold configuration
        # Use this file to configure rate limiting and suppression rules
        # See: https://docs.suricata.io/en/latest/configuration/rule-management.html

        # Example: Suppress noisy alerts from specific IP
        # suppress gen_id 1, sig_id 1000001, track by_src, ip 192.168.1.1

        # Example: Rate limit SSH brute force alerts
        # threshold gen_id 1, sig_id 1000001, type limit, track by_src, count 1, seconds 60

        suppress gen_id 1, sig_id 2200121
      '';
    };

    systemd.services.suricata = {
      preStart = ''
        mkdir -p /var/lib/suricata/rules
        # Pour le premier run, si tu as des erreurs de règles manquantes, décommente la ligne suivante :
        # ${pkgs.suricata}/bin/suricata-update --no-reload || true
      '';
    };
  };
}
