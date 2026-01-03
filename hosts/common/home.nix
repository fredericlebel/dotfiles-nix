{ pkgs, ... }: {

  imports = [
    ../../modules/programs/gpg
    ../../modules/programs/starship
    ../../modules/programs/yazi
    ../../modules/programs/zsh
  ];

  my.programs = {
    gpg.enable = true;
    starship.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

home = {
    stateVersion = "24.05";

    packages = with pkgs; [
      # --- Base System ---
      bat
      ffmpeg
      fzf
      gnupg
      jq
      ripgrep
      tree
      wget

      # --- Rust ---
      cargo
      rustc
      rustfmt

      # --- DevOps / Infrastructure ---
      ansible
      ansible-lint
      docker
      docker-compose
      podman
      podman-compose

      # --- Kubernetes ---
      fluxcd
      k9s
      kubectl
      kubernetes-helm
      kustomize

      # --- Réseau & Sécurité ---
      age
      aircrack-ng
      nmap
      sops
      sshpass
      tailscale
      wireshark-cli

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
