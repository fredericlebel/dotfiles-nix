{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.cli.desktop-utils;
in
{
  options.my.features.cli.desktop-utils = {
    enable = lib.mkEnableOption "Outils CLI spécifiques à la station de travail (Dev, DevOps, Réseau)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Kubernetes & DevOps
      fluxcd
      k9s
      kubectl
      kubernetes-helm
      kustomize

      # Réseau & Sécurité
      age
      nmap
      sops
      sshpass
      wireshark-cli

      # Développement
      gh
      just
      python3
      yq-go
      wrkflw
    ];
  };
}
