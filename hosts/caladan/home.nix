{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../common/home.nix
    ../../modules/features/containers
    ../../modules/features/gpg
  ];

  my.features = {
    containers.enable = true;
    gpg.enable = true;
    zsh.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
  };
}
