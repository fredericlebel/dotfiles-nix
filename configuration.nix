{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    # Outils Système de base
    bat
    tree
    fzf
    jq
    ripgrep
    wget
    gnupg
    ffmpeg

    # rust et outils associés
    rustc
    cargo
    rustfmt

    # DevOps / Infrastructure
    ansible
    ansible-lint
    docker
    docker-compose
    podman
    podman-compose
    colima
    qemu

    # Kubernetes
    kubectl
    k9s
    kubernetes-helm
    kustomize
    fluxcd

    # Réseau & Sécurité
    nmap
    wireshark-cli
    aircrack-ng
    sops
    age
    sshpass
    tailscale

    # Développement
    git
    gh
    nodejs
    python3
    just
    yq-go
    tmux
    direnv
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    taps = [
      "nikitabobko/tap"
    ];

    casks = [
      # Navigateurs & Com
      "google-chrome"
      "discord"
      "zoom"
      "spotify"

      # Outils Tech
      "visual-studio-code"
      "wezterm"
      "wireshark-app"
      "pgadmin4"
      "podman-desktop"
      "caido"
      "maccy"

      # Productivité & Système
      "logseq"
      "bitwarden"
      "google-drive"
      "aerospace"
      "alt-tab"

      # Fonts (Installées via Brew c'est souvent plus simple pour les Casks)
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"
    ];

    # Outils CLI qu'on laisse à Homebrew
    brews = [
      "bettercap"
      "mas"
      "wifi-password"
    ];

    # Apps du Mac App Store (Tu devras trouver les IDs avec `mas search`)
    masApps = {
      "Bitwarden" = 1352778147;
      "Tailscale" = 1475387142;
    };
  };

  users.users.flebel = {
    name = "flebel";
    home = "/Users/flebel";
  };
  system.primaryUser = "flebel";
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;

      persistent-apps = [
        "/Applications/Google Chrome.app"
        "/Applications/WezTerm.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Logseq.app"
        "/Applications/Spotify.app"
        "/Applications/Discord.app"
        "/Applications/Bitwarden.app"
        "/System/Applications/System Settings.app"
      ];
    };

    NSGlobalDomain.NSWindowResizeTime = 0.001;

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;       # Affiche le chemin en bas de la fenêtre
      FXEnableExtensionChangeWarning = false; # Désactive l'alerte quand tu changes une extension
    };
  };

  nix.enable = false;
  system.stateVersion = 4;
}
