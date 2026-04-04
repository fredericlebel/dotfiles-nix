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
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
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
