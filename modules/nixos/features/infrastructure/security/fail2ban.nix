{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.infrastructure.security.fail2ban;
in
{
  options.my.features.infrastructure.security.fail2ban = {
    enable = lib.mkEnableOption "Fail2ban Intrusion Prevention System";
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;

      # Utilisation de nftables (plus moderne et déjà actif sur vos hôtes)
      banaction = "nftables-multiport";
      banaction-allports = "nftables-allports";

      # Configuration globale
      maxretry = 5; # Bannissement après 5 tentatives échouées
      bantime = "1h"; # Temps de bannissement initial
      bantime-increment = {
        enable = true; # Augmente le temps si l IP revient souvent
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # Maximum 1 semaine
      };

      jails = {
        # Protection SSH (activée par défaut)
        ssh-iptables = ''
          enabled  = true
          filter   = sshd
          port     = ssh
          logpath  = %(sshd_log)s
          backend  = %(sshd_backend)s
        '';
      };
    };

    # Collecte des métriques KPI/KRI via Textfile Collector
    systemd.services.fail2ban-metrics-collector = {
      description = "Collect Fail2ban metrics for Prometheus";
      after = [ "fail2ban.service" ];
      path = with pkgs; [
        fail2ban
        gawk
        coreutils
        sqlite
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "collect-f2b-metrics" ''
          set -euo pipefail
          METRICS_DIR="/var/lib/prometheus-node-exporter-textfiles"
          mkdir -p "$METRICS_DIR"
          DB_PATH="/var/lib/fail2ban/fail2ban.sqlite3"

          # 1. Extraction des stats en temps reel (KPI Performance)
          BANNED_NOW=$(fail2ban-client status ssh-iptables | grep "Currently banned" | awk -F: '{ print $2 }' | tr -d '[:space:]' || echo "0")
          FAILED_TOTAL=$(fail2ban-client status ssh-iptables | grep "Total failed" | awk -F: '{ print $2 }' | tr -d '[:space:]' || echo "0")

          # 2. Extraction des donnees historiques (KRI Risque) - Uniquement si la DB existe
          BANNED_HISTORY=0
          REPEAT_OFFENDERS=0
          VELOCITY_1H=0
          BOTNET_RATIO=0
          PERSISTENCE_SCORE=0

          if [ -f "$DB_PATH" ]; then
            # Nombre total de bannissements (KPI)
            BANNED_HISTORY=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM bans;" || echo "0")
            
            # Recidivistes (KRI)
            REPEAT_OFFENDERS=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM (SELECT ip FROM bans GROUP BY ip HAVING count(ip) > 1);" || echo "0")
            
            # Velocité : Bans dans la derniere heure (KRI)
            VELOCITY_1H=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM bans WHERE timeofban > strftime('%s', 'now') - 3600;" || echo "0")
            
            # Densite Botnet : IP Uniques / Total Bans (KRI)
            BOTNET_RATIO=$(sqlite3 "$DB_PATH" "SELECT CASE WHEN count(*) > 0 THEN CAST(count(DISTINCT ip) AS FLOAT) / count(*) ELSE 0 END FROM bans;" || echo "0")
            
            # Score de Persistance : IPs bannies plus de 3 fois (KRI)
            PERSISTENCE_SCORE=$(sqlite3 "$DB_PATH" "SELECT count(*) FROM bans WHERE bancount > 3;" || echo "0")
          fi

          # 3. Ecriture au format Prometheus
          cat <<EOF > "$METRICS_DIR/fail2ban.prom.$$.tmp"
          # HELP fail2ban_banned_current Number of currently banned IPs
          # TYPE fail2ban_banned_current gauge
          fail2ban_banned_current{jail="ssh-iptables"} ''${BANNED_NOW:-0}

          # HELP fail2ban_failed_total Total number of failed attempts
          # TYPE fail2ban_failed_total counter
          fail2ban_failed_total{jail="ssh-iptables"} ''${FAILED_TOTAL:-0}

          # HELP fail2ban_banned_history_total Total number of bans in history
          # TYPE fail2ban_banned_history_total counter
          fail2ban_banned_history_total{jail="ssh-iptables"} ''${BANNED_HISTORY:-0}

          # HELP fail2ban_repeat_offenders_total Number of unique IPs banned more than once
          # TYPE fail2ban_repeat_offenders_total gauge
          fail2ban_repeat_offenders_total{jail="ssh-iptables"} ''${REPEAT_OFFENDERS:-0}

          # HELP fail2ban_attack_velocity_1h Number of bans in the last hour
          # TYPE fail2ban_attack_velocity_1h gauge
          fail2ban_attack_velocity_1h{jail="ssh-iptables"} ''${VELOCITY_1H:-0}

          # HELP fail2ban_botnet_density_ratio Ratio of unique IPs over total bans
          # TYPE fail2ban_botnet_density_ratio gauge
          fail2ban_botnet_density_ratio{jail="ssh-iptables"} ''${BOTNET_RATIO:-0}

          # HELP fail2ban_persistence_score_total Number of IPs banned more than 3 times
          # TYPE fail2ban_persistence_score_total gauge
          fail2ban_persistence_score_total{jail="ssh-iptables"} ''${PERSISTENCE_SCORE:-0}
          EOF

          mv "$METRICS_DIR/fail2ban.prom.$$.tmp" "$METRICS_DIR/fail2ban.prom"
        '';
      };
    };

    systemd.timers.fail2ban-metrics-collector = {
      description = "Run Fail2ban metrics collector every minute";
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
