{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.infrastructure.security.hardening;
in
{
  options.my.features.infrastructure.security.hardening = {
    enable = lib.mkEnableOption "Durcissement du noyau et du système";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernel.sysctl = {
        # --- Kernel Protections ---
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "kernel.sysrq" = 0;
        "kernel.yama.ptrace_scope" = 1;

        # --- Filesystem Protections ---
        "fs.protected_hardlinks" = 1;
        "fs.protected_symlinks" = 1;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
        "fs.suid_dumpable" = 0;

        # --- Network Stack Hardening ---
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;

        # Disable ICMP Redirect Acceptance (Anti-Spoofing / Anti-MITM)
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;

        # Disable ICMP Redirect Sending
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;

        # Disable IP Source Routing
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
      };

      tmp = {
        cleanOnBoot = true;
        useTmpfs = true;
      };
    };

    fileSystems."/boot".options = [ "umask=0077" ];
  };
}
