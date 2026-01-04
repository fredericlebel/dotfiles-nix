{
  pkgs,
  user,
  ...
}: {
  imports = [../common/home.nix];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };
}
