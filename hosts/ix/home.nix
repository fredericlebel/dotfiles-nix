{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../modules/home/git
    ../../modules/home/zsh
  ];

  my.features = {
    git.enable = true;
    zsh.enable = true;
  };

  home = {
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";
    username = user;
  };
}
