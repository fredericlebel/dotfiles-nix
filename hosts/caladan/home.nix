{ pkgs, user, ... }: {

  imports = [
    ../common/home.nix
    ../../modules/programs/aerospace
    ../../modules/programs/wezterm
  ];

  my.programs = {
    aerospace.enable = true;
    wezterm.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/Users/${user}";

    packages = with pkgs; [
      # Outils spécifiques macOS uniquement
      colima
    ];
  };
}
