{
  config,
  lib,
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
  };
}
