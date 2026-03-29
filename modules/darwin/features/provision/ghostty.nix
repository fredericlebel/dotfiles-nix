{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.terminals.ghostty;
in
{
  options.my.features.terminals.ghostty = {
    enable = lib.mkEnableOption "Ghostty (via Homebrew)";
  };

  config = lib.mkIf cfg.enable {
    homebrew.enable = true;

    homebrew.casks = [
      "ghostty"
    ];
  };
}
