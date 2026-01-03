{ pkgs, ... }: {

  imports = [
    ./modules/programs/aerospace
    ./modules/programs/gpg
    ./modules/programs/wezterm
  ];

  my.programs = {
    aerospace.enable = true;
    gpg.enable = true;
    wezterm.enable = true;
  };

  home = {
    username = "flebel";
    homeDirectory = "/Users/flebel";
    stateVersion = "24.05";
    packages = with pkgs; [
      bat
      fzf
      ripgrep
      jq
    ];
  };

  # Exemple de config programme
  # programs.zsh.enable = true;
  # programs.git = {
  #  enable = true;
  #  userName = "Ton Nom";
  #  userEmail = "ton.email@exemple.com";
  # };
}
