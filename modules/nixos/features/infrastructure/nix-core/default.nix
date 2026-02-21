{
  config,
  lib,
  ...
}:
let
  cfg = config.my.features.infrastructure.nix-core;
in
{
  options.my.features.infrastructure.nix-core.enable = lib.mkEnableOption "Core Nix daemon settings & GC";

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
  };
}
