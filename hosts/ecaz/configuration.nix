{
  config,
  modulesPath,
  user,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix

    ../../users/${user}/system.nix

    ../../modules/nixos/bundles/base-server.nix
    ../../modules/nixos/features/infrastructure/security/openssh.nix
    ../../modules/nixos/features/infrastructure/tailscale.nix
  ];

  my.bundles.base-server.enable = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  users.users.${user} = {
    extraGroups = [
      "wheel"
    ];
    home = "/home/${user}";
  };

  my.features = {
    infrastructure = {
      tailscale = {
        enable = true;
        isExitNode = true;
        authKeyFile = config.sops.secrets.tailscale-key.path;
      };
    };
  };

  networking = {
    hostName = "ecaz";
    domain = "opval.com";

    firewall = {
      enable = true;
    };
    nftables.enable = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

  sops.secrets.tailscale-key = { };

  sops = {
    defaultSopsFile = ../../secrets/ecaz.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  system.stateVersion = "26.05";
}
