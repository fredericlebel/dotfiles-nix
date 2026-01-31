{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.security.hardening;
in {
  options.my.features.security.hardening = {
    enable = lib.mkEnableOption "Durcissement du noyau et du système";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_hardened;

    boot.kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.unprivileged_bpf_disabled" = 1;
    };

    boot.tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    fileSystems."/boot".options = ["umask=0077"];
  };
}
