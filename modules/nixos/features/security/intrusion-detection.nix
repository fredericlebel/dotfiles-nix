{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.my.features.security.intrusion-detection;

  aideUpdateScript = pkgs.writeShellScriptBin "aide-accept-changes" ''
    if [ "$EUID" -ne 0 ]; then
      echo "Error: Please run as root"
      exit 1
    fi

    echo "🔍 Updating AIDE database to match current system state..."
    echo "   (This may take a few minutes)..."

    # On lance l'update
    ${pkgs.aide}/bin/aide --update

    # Si succès, on écrase l'ancienne DB avec la nouvelle
    if [ $? -eq 0 ] || [ $? -lt 8 ]; then
      mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
      echo "Database updated. New baseline established."
    else
      echo "Error during AIDE update."
      exit 1
    fi
  '';
in
{
  options.my.features.security.intrusion-detection = {
    enable = lib.mkEnableOption "AIDE File Integrity Monitoring";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.aide
      aideUpdateScript
    ];

    environment.etc."aide.conf".text = ''
      # --- AIDE Configuration for NixOS ---

      # Database paths
      database_in=file:/var/lib/aide/aide.db
      database_out=file:/var/lib/aide/aide.db.new

      # Logging & Reporting
      report_url=stdout
      log_level=warning
      report_level=changed_attributes
      report_summarize_changes=yes

      # --- MACROS ---
      # p=perm, i=inode, n=link count, u=user, g=group, s=size,
      # b=block count, m=mtime, c=ctime, S=size growing

      # Hashing : SHA256 + SHA512 (Moderne et robuste)
      HASHES = sha256+sha512

      # Rules
      CRITICAL = p+i+n+u+g+s+b+m+c+HASHES
      CONFIG   = p+i+n+u+g+s+b+m+c+sha256
      LOGS     = p+i+n+u+g+S
      DIR      = p+i+n+u+g

      # --- WATCHLIST (Adapté à l'architecture Nix) ---

      # 1. Le Cœur du Système (Immutable sur NixOS)
      # Sur NixOS, /bin et /usr/bin sont des symlinks. On surveille la CIBLE réelle.
      # /run/current-system contient tout l'état actuel de ton OS.
      /run/current-system/sw/bin CRITICAL
      /run/current-system/etc    CRITICAL
      /boot                      CRITICAL

      # 2. Configuration Mutable (Stateful)
      /etc/nixos                 CONFIG
      /etc/ssh                   CRITICAL

      # Secrets (Attention aux permissions)
      /etc/nixos/secrets.yaml    CONFIG
      # On exclut les clés privées pour éviter les faux positifs sur les permissions strictes
      # ou pour ne pas toucher au contenu sensible, on vérifie juste qu'elles existent
      !/etc/ssh/ssh_host_.*_key
      /etc/ssh/ssh_host_.*_key.pub CRITICAL

      # 3. Répertoires Système Critiques (Métadonnées seulement)
      /root                      DIR
      /var/lib                   DIR

      # --- EXCLUSIONS (Bruit et Faux Positifs) ---

      # Nix Store : C'est read-only et immutable.
      # Le vérifier via AIDE est inutilement lourd (des millions de fichiers).
      # On fait confiance à 'nix store verify' pour ça.
      !/nix/store

      # Runtime & Logs dynamiques
      !/var/log
      !/var/run
      !/run
      !/tmp
      !/sys
      !/proc
      !/dev
      !/var/cache
      !/home/.*/.cache
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/aide 0700 root root -"
      "d /var/log/aide 0755 root root -"
    ];

    systemd.services.aide-init = {
      description = "Initialize AIDE database (Manual Run Only)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.aide}/bin/aide --init";
        ExecStartPost = "${pkgs.coreutils}/bin/mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db";
      };
    };

    systemd.services.aide-check = {
      description = "AIDE Intrusion Detection Check";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${pkgs.aide}/bin/aide --check";
      };
    };

    systemd.timers.aide-check = {
      description = "Daily AIDE Check";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
        Unit = "aide-check.service";
      };
    };
  };
}
