{user, ...}: {
  imports = [
    ../../users/${user}/base.nix
    ../../modules/home/bundles/desktop
  ];

  my.bundles.desktop.enable = true;

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
  };
}
