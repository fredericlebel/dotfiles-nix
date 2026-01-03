{ lib, config, pkgs, ... }:

let
  cfg = config.my.programs.wezterm;
in
{
  options.my.programs.wezterm = {
    enable = lib.mkEnableOption "WezTerm configuration";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."wezterm/wezterm.lua".source = ../../../config/wezterm/wezterm.lua;
  };
}
