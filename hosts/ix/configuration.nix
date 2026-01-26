{
  pkgs,
  modulesPath,
  myMeta,
  user,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ../../modules/nixos/aide
    ../../modules/nixos/suricata
    ../../modules/nixos/openssh
    ../../modules/nixos/vaultwarden
    ../../modules/nixos/zsh
  ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    kernelPackages = pkgs.linuxPackages_hardened;
    kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.unprivileged_bpf_disabled" = 1;
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
  };

  fileSystems."/boot".options = ["umask=0077"];

  my.services = {
    aide.enable = true;
    openssh.enable = true;
    suricata = {
      enable = true;
      interface = "ens3";
    };
    vaultwarden.enable = true;
  };

  environment.systemPackages = with pkgs; [
    btop
    ethtool
    htop
    jq
    tcpdump
  ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443];
      allowedUDPPorts = [];
      extraInputRules = ''
        tcp dport 22 ct state new,untracked limit rate 3/minute accept
        tcp dport 22 drop
      '';
      trustedInterfaces = ["tailscale0"];
    };
    hostName = "ix";
    nftables.enable = true;
  };

  programs.zsh.enable = true;

  time.timeZone = "America/Montreal";

  users = {
    #defaultUserShell = pkgs.zsh;
    users = {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
      ];

      "${user}" = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
        ];
      };
    };
  };

  security.doas = {
    enable = true;
    extraRules = [
      {
        users = ["flebel"];
        keepEnv = true;
        persist = true;
      }
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  sops = {
    defaultSopsFile = ../../secrets/ix.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  system.stateVersion = "26.05";
}
