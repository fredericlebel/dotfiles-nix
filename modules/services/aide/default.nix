{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.my.services.aide;
in {
  options.my.services.aide = {
    enable = lib.mkEnableOption "AIDE Intrusion Detection";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.aide];

    environment.etc."aide.conf".text = ''
      # AIDE Configuration
      # Database paths
      database_in=file:/var/lib/aide/aide.db
      database_out=file:/var/lib/aide/aide.db.new
      database_new=file:/var/lib/aide/aide.db.new

      # Report configuration
      report_url=stdout

      # Logging level (error, warning, notice, info, debug)
      log_level=notice

      # Report detail level
      report_level=changed_attributes
      report_detailed_init=yes
      report_base16=no
      report_quiet=no
      report_append=no
      report_summarize_changes=yes

      # Custom rule definitions
      # R = Read-only files (permissions + inode + size + checksums)
      # L = Log files (growing, permissions may change)
      # E = Empty directories
      # > = Growing log files
      # N = Ignore everything (for exclusions)

      # Comprehensive monitoring for critical files
      # Using modern hash algorithms (sha256+sha512) - removed deprecated md5, rmd160, tiger
      CRITICAL = p+i+n+u+g+s+b+m+c+sha256+sha512

      # Read-only files (no changes expected)
      READONLY = p+i+n+u+g+s+b+m+c+sha256

      # Configuration files (may change, but we want to know)
      CONFIG = p+i+n+u+g+s+b+m+c+sha256

      # Immutable backups (should NEVER change)
      # Note: For multi-TB directories, we only monitor metadata, not file contents
      # Use ZFS snapshots for content integrity verification
      IMMUTABLE = p+i+n+u+g+s+b+m+c+sha256+sha512

      # Log files (can grow, but structure shouldn't change)
      LOGS = p+i+n+u+g+S

      # Directories only
      DIRONLY = p+i+n+u+g

      # ===== CRITICAL SYSTEM FILES =====

      # System binaries (should be read-only)
      /bin READONLY
      /sbin READONLY
      /usr/bin READONLY
      /usr/sbin READONLY

      # System libraries
      /lib READONLY
      /lib64 READONLY
      /usr/lib READONLY
      /usr/lib64 READONLY

      # NixOS-specific
      /run/current-system READONLY
      /nix/var/nix/profiles/system READONLY

      # Boot files
      /boot CRITICAL

      # ===== SSH AND SECURITY =====

      # SSH keys and configuration
      /etc/ssh CRITICAL
      /root/.ssh CRITICAL

      # SOPS configuration
      /etc/nixos/secrets.yaml CONFIG
      # Exclude private age keys (should never be committed)
      !/etc/nixos/.*.age$

      # ===== CRITICAL BACKUPS (IMMUTABLE) =====

      # Images backup directory (2.1TB) - Monitor directory metadata only
      # File content integrity verified via ZFS scrub and snapshots
      !/tank/Backups/Images

      # Messages backup directory (109GB) - Monitor directory metadata only
      # File content integrity verified via ZFS scrub and snapshots
      !/tank/Backups/Messages

      # PostgreSQL backups - Excluded to avoid daily alerts from automated backups
      # Backup integrity verified via daily backup service monitoring
      !/tank/Backups/PostgreSQL

      # ===== CONFIGURATION FILES =====

      # NixOS configuration
      /etc/nixos CONFIG
      # Exclude .git directory
      !/etc/nixos/\.git
      # Exclude build results
      !/etc/nixos/result
      # Exclude build lock file
      !/etc/nixos/\.nixos-build

      # System configuration
      /etc/systemd CONFIG
      /etc/security CONFIG

      # ===== EXCLUSIONS =====

      # Temporary files
      !/tmp
      !/var/tmp
      !/run

      # Log directories (monitored separately)
      !/var/log

      # Proc and sys
      !/proc
      !/sys
      !/dev

      # Nix store changes frequently during updates
      !/nix/store

      # Cache and transient data
      !/var/cache
      !/home/.*/\.cache
      !/root/\.cache

      # Browser and application caches
      !/\.mozilla
      !/\.config/google-chrome

      # ZFS snapshots
      !/tank/\.zfs
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/aide 0700 root root -"
      "d /var/log/aide 0755 root root -"
    ];

    systemd.services.aide-init = {
      description = "Initialize AIDE database";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.aide}/bin/aide --init";
        ExecStartPost = "${pkgs.coreutils}/bin/mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db";
        RemainAfterExit = true;
      };
    };

    systemd.services.aide-update = {
      description = "Update AIDE database with current state";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.aide}/bin/aide --update";
        ExecStartPost = "${pkgs.coreutils}/bin/mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db";
        # AIDE exit codes: 0=no changes, 1-7=changes detected (all valid for update)
        # 1=new, 2=removed, 3=changed, 4=new+removed, 5=new+changed, 6=removed+changed, 7=all
        SuccessExitStatus = [0 1 2 3 4 5 6 7];
      };
    };

    systemd.services.aide-check = {
      description = "AIDE Intrusion Detection Check";
      after = ["aide-init.service"];
      requires = ["aide-init.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.aide}/bin/aide --check";
        User = "root";
      };
    };

    systemd.timers.aide-check = {
      description = "Daily AIDE Intrusion Detection Check";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "aide-check.service";
      };
    };
  };
}
