{pkgs, ...}: {
  imports = [
    ../../modules/home/gpg
    ../../modules/home/starship
    ../../modules/home/yazi
    #../../modules/home-manager/zsh
  ];

  my.features = {
    starship.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      # --- Base System ---
      bat
      fzf
      gnupg
      jq
      ripgrep
      tree
      wget

      # --- DevOps / Infrastructure ---
      podman
      podman-compose

      # --- Réseau & Sécurité ---
      age
      nmap
      sops
      tailscale
      tcpdump

      # --- Développement ---
      direnv
      gh
      git
      just
      nodejs
      python3
      tmux
      yq-go
    ];
  };
}
