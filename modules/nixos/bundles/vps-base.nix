{
  config,
  lib,
  modulesPath,
  user,
  ...
}:
let
  cfg = config.my.bundles.vps-base;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./base-server.nix
  ];

  options.my.bundles.vps-base = {
    enable = lib.mkEnableOption "Configuration de base pour VPS (Contabo/cloud)";
  };

  config = lib.mkIf cfg.enable {
    my.bundles.base-server.enable = true;

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 2048;
      }
    ];

    networking = {
      domain = "opval.com";
      firewall = {
        enable = true;
      };
      nftables.enable = true;
    };

    users.users.${user} = {
      extraGroups = [
        "wheel"
      ];
      home = "/home/${user}";
    };

    sops.secrets.tailscale-key = {
      owner = "root";
      mode = "0400";
    };

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    system.stateVersion = config.myMeta.defaultStateVersion;
  };
}
