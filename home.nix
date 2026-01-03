{ pkgs, ... }: {

  imports = [
    ./modules/programs/aerospace  # Nix cherche automatiquement le "default.nix" dedans
    ./modules/programs/gpg
    # ./modules/programs/wezterm  # (Pour quand tu feras pareil avec Wezterm)
  ];

  my.programs.aerospace.enable = true;
  my.programs.gpg.enable = true;
  
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
