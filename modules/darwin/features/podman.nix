{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.podman;
  # On ne peut pas facilement ajouter des casks conditionnels
  # via nix-homebrew sans injecter dans homebrew.casks
in
{
  options.my.features.podman = {
    enable = lib.mkEnableOption "Podman & Podman Desktop (Alternative Docker)";
  };

  config = lib.mkIf cfg.enable {
    homebrew.casks = [ "podman-desktop" ];

    environment.systemPackages = [
      pkgs.podman
      pkgs.podman-compose
    ];

    # Ajout de l'icône au Dock
    my.registry.dockApps = [ "/Applications/Podman Desktop.app" ];
  };
}
