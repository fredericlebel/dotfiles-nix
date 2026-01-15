{
  pkgs,
  modulesPath,
  user,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ../../modules/features/tailscale
    ../../modules/services/aide
  ];

  my.features= {
    tailscale.enable = true;
  };

  my.services = {
    aide.enable = true;
  };

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
    firewall = {
      enable = true;

      allowedTCPPorts = [22];
      allowedUDPPorts = [];
      trustedInterfaces = ["tailscale0"];
    };
    hostName = "ix";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = "America/Montreal";

  programs.zsh = {
    enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
      ];

      "${user}" = {
        isNormalUser = true;
        extraGroups = ["wheel" "docker"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
        ];
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "26.05";
}
