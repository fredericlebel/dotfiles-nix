{ lib, config, ... }:
let
  cfg = config.my.features.gemini-cli;
in
{
  options.my.features.gemini-cli = {
    enable = lib.mkEnableOption "Gemini CLI tool (via Homebrew)";
  };

  config = lib.mkIf cfg.enable {
    homebrew.brews = [ "gemini-cli" ];
  };
}
