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

    home.packages = [
      pkgs.podman
      pkgs.podman-compose
    ];

    # Optionnel: on peut aussi ajouter au Dock si on le souhaite
    # my.registry.dockApps = [ "/Applications/Podman Desktop.app" ];
  };
}
