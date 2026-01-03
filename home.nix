{ pkgs, ... }: {

  imports = [
    ./modules/programs/aerospace
    ./modules/programs/gpg
    ./modules/programs/wezterm
  ];

  my.programs.aerospace.enable = true;
  my.programs.gpg.enable = true;
  my.programs.wezterm.enable = true;
  
  home.username = "flebel";
  home.homeDirectory = "/Users/flebel";
  
  home.stateVersion = "24.05"; 

  home.packages = with pkgs; [
    bat
    fzf
    ripgrep
    jq
  ];

  # Exemple de config programme
  # programs.zsh.enable = true;
  # programs.git = {
  #  enable = true;
  #  userName = "Ton Nom";
  #  userEmail = "ton.email@exemple.com";
  # };
}
