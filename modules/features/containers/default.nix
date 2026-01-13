{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.containers;

  # Des booléens pour rendre le code plus lisible
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  options.my.features.containers = {
    enable = lib.mkEnableOption "Stack Conteneurs (Podman/Docker)";
  };

  config = lib.mkIf cfg.enable {
    # --- PARTIE COMMUNE (Mac & Linux) ---
    # Les outils qu'on veut partout
    home.packages = with pkgs;
      [
        podman-compose # Ou docker-compose
        lazydocker # Le TUI
      ]
      ++ lib.optionals isDarwin [
        # --- SPÉCIFIQUE MAC ---
        # Sur Mac, on a besoin de la VM et du client
        pkgs.colima
        pkgs.podman
      ];

    # --- ALIAS COMMUNS ---
    home.shellAliases =
      {
        d = "podman";
        dc = "podman-compose";
        k = "kubectl";
      }
      // lib.optionalAttrs isDarwin {
        # Alias spécifique pour démarrer la VM sur Mac
        start-colima = "colima start --runtime podman --cpu 2 --memory 4";
      };

    # --- SPÉCIFIQUE MAC (Socket) ---
    home.sessionVariables = lib.mkIf isDarwin {
      # Sur Linux, le socket est standard (/run/podman/podman.sock)
      # Sur Mac via Colima, il est ailleurs :
      DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
    };
  };
}
