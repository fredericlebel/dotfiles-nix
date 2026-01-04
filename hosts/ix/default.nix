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
  ];

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

  networking.hostName = "ix";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
  ];

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJH/EaFTiyNBESMu48Gzm5tqe0NW53+utml1n469P46 flebel@opval.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "24.05";
}
