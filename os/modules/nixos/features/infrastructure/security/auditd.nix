{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.infrastructure.security.auditd;
in
{
  options.my.features.infrastructure.security.auditd = {
    enable = lib.mkEnableOption "Auditd system auditing";
  };

  config = lib.mkIf cfg.enable {
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        # 1. Surveillance des modifications de fichiers sensibles
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/sudoers -p wa -k identity"
        "-w /etc/doas.conf -p wa -k identity"

        # 2. Surveillance du réseau (changements de config)
        "-w /etc/hostname -p wa -k network"
        "-w /etc/network/ -p wa -k network"

        # 3. Surveillance des exécutions suspectes
        "-a always,exit -F arch=b64 -S execve -k execution"

        # 4. Surveillance des montages / démontages
        "-a always,exit -F arch=b64 -S mount -S umount2 -k export"

        # 5. Surveillance des changements d heure
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time"
      ];
    };

    # Outil pour analyser les logs plus facilement
    environment.systemPackages = [ pkgs.audit ];
  };
}
