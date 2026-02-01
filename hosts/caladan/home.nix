{ user, ... }:
{
  imports = [
    ../../users/${user}/home.nix
    ../../modules/home/bundles/desktop.nix
  ];

  my.bundles.desktop.enable = true;

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
  };
}
