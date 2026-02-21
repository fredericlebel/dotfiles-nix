{ user, ... }:
{
  imports = [
    ../../users/${user}/home.nix
    ../../modules/home/bundles/desktop.nix
  ];

  my.bundles.desktop.enable = true;
}
