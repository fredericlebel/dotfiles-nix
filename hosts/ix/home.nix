{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../users/${user}/base.nix
    ../../modules/home/bundles/server.nix
  ];

  my.bundles.server.enable = true;

  home = {
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";
    username = user;
  };
}
