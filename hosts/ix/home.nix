{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../users/flebel/home.nix
    ../../modules/home/bundles/server.nix
  ];

  my.bundles.server.enable = true;

  #home = {
  #  homeDirectory = "/home/${user}";
  #  stateVersion = "26.05";
  #  username = user;
  #};
}
