{user, ...}: {
  imports = [
    ../../users/${user}/base.nix
    ../../modules/home/bundles/desktop.nix
  ];

  my.bundles.desktop.enable = true;

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
  };
}
