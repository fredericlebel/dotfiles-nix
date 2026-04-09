{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.infrastructure.nix-core;
in
{
  options.my.features.infrastructure.nix-core.enable =
    lib.mkEnableOption "Core Nix daemon settings & GC";

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Conserver les derivations pour permettre le debug si besoin, 
        # mais supprimer les outputs inutilises
        keep-outputs = true;
        keep-derivations = true;
      };

      # Optimisation hebdomadaire du store (hard-links)
      optimise.automatic = true;

      # Garbage Collection automatique
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    # Script pour supprimer les vieilles generations de systeme 
    # (sinon la GC ne peut pas les supprimer du store)
    system.activationScripts.cleanup-generations = {
      text = ''
        ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +10
      '';
    };

    boot.kernel.sysctl = {
      # Nécessaire pour le sandboxing de Nix (isolation des builds).
      # Bien que le noyau 'hardened' le désactive par défaut pour limiter la surface d'attaque,
      # son activation est indispensable pour permettre à Nix de construire des dérivations
      # en mode sandbox, particulièrement lors de builds distants ou sur la cible.
      "kernel.unprivileged_userns_clone" = 1;
    };
  };
}
