{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../common/core.nix
    ../../modules/home/git
    ../../modules/home/zsh
  ];

  my.features = {
    git.enable = true;
    zsh.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };
}
