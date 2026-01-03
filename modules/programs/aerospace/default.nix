{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.aerospace;
in {
  options.my.programs.aerospace = {
    enable = lib.mkEnableOption "Aerospace Window Manager";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."aerospace/aerospace.toml".source = ../../../config/aerospace/aerospace.toml;

    # Optionnel : Tu peux aussi installer le package ici si tu veux que ce module soit autonome
    # home.packages = [ pkgs.aerospace ]; # (Si le paquet existait dans pkgs, sinon via cask comme on a fait)
  };
}
