{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../common/home.nix
    ../../modules/programs/aerospace
    ../../modules/programs/wezterm
  ];

  my.programs = {
    aerospace.enable = true;
    gpg.enable = true;
    zsh.enable = true;
    wezterm.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/Users/${user}";

    packages = with pkgs; [
      colima
    ];
  };
}
