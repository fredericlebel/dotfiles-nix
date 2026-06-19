{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.features.antigravity-cli;
in
{
  options.my.features.antigravity-cli = {
    enable = lib.mkEnableOption "Antigravity CLI (agy), the successor to Gemini CLI";
  };

  config = lib.mkIf cfg.enable {
    # Antigravity CLI is provided via the flake
    environment.systemPackages = [
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
    ];
  };
}
