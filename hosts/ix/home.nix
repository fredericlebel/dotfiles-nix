{
  pkgs,
  user,
  ...
}: {
  imports = [../common/core.nix];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };
}
