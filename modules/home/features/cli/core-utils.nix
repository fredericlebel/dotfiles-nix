{ config, lib, pkgs, ... }:

let
  cfg = config.my.features.cli.core-utils;
in
{
  options.my.features.cli.core-utils = {
    enable = lib.mkEnableOption "Outils CLI essentiels (bat, eza, fzf, htop, direnv)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      curl
      wget
      jq
      ripgrep
      fd
      ncdu
    ];

    programs.htop.enable = true;

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

  };
}
