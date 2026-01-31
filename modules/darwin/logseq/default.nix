{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.logseq;
in
{
  options.my.features.logseq = {
    enable = lib.mkEnableOption "Logseq Knowledge Base (via Homebrew)";
  };

  config = lib.mkIf cfg.enable {
    homebrew.enable = true;

    homebrew.casks = [
      "logseq"
    ];
  };
}
