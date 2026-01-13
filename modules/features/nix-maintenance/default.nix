{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.nix-maintenance;
in {
  options.my.features.nix-maintenance = {
    enable = lib.mkEnableOption "Active nix maintenance (GC & Optimisation)";
  };

  config = lib.mkIf cfg.enable {
    # On ne touche PAS à nix.enable ni nix.settings
    # car ton 'default.nix' dit nix.enable = false.

    # À la place, on crée un agent launchd manuel pour nettoyer le système
    launchd.agents.nix-gc = {
      serviceConfig = {
        # La commande exacte pour nettoyer les vieux fichiers
        ProgramArguments = [
          "${pkgs.nix}/bin/nix-collect-garbage"
          "--delete-older-than"
          "7d"
        ];

        # Planification : Chaque dimanche à 02:00 du matin
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 2;
            Minute = 0;
          }
        ];

        # Options de log pour voir si ça a marché (dans Console.app)
        StandardOutPath = "/tmp/nix-gc.log";
        StandardErrorPath = "/tmp/nix-gc.error.log";
      };
    };
  };
}
