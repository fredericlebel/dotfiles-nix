{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.editors.vscode;
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in
{
  options.my.features.editors.vscode = {
    enable = lib.mkEnableOption "vscode avec intégration Zsh, Nix (LSP) et Direnv";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      nil # Le Language Server pour Nix
      alejandra # Le formateur que tu as configuré
      nixfmt-rfc-style # (Optionnel) Alternative de formatage
    ];

    programs.vscode = {
      enable = true;

      profiles = {
        default = {
          extensions = [
            # --- Langages & Formatage ---
            marketplace.jnoortheen.nix-ide

            marketplace.kamadorueda.alejandra
            marketplace.rust-lang.rust-analyzer
            marketplace.tamasfe.even-better-toml
            marketplace.redhat.vscode-yaml
            marketplace.bluebrown.yamlfmt
            marketplace.blueglassblock.better-json5
            marketplace.wholroyd.jinja
            marketplace.editorconfig.editorconfig

            # --- Python ---
            marketplace.ms-python.python
            marketplace.ms-python.debugpy
            #marketplace.ms-python.vscode-pylance
            marketplace.ms-python.vscode-python-envs

            # --- Intelligence Artificielle ---
            #marketplace.github.copilot
            #marketplace.github.copilot-chat
            marketplace.google.geminicodeassist

            # --- Docker & Remote ---
            #marketplace.docker.docker
            #marketplace.ms-azuretools.vscode-docker
            #marketplace.ms-azuretools.vscode-containers
            #marketplace.ms-vscode-remote.remote-containers
            #marketplace.ms-vscode.remote-repositories

            # --- GitHub & Git ---
            marketplace.github.github-vscode-theme
            marketplace.github.remotehub
            marketplace.github.vscode-github-actions
            marketplace.github.vscode-pull-request-github
            marketplace.ms-vscode.azure-repos

            # --- Utilitaires & UI ---
            marketplace.pkief.material-icon-theme
            marketplace.signageos.signageos-vscode-sops

            # AJOUTÉ : Indispensable pour charger le contexte du dossier (flake/devShell)
            marketplace.mkhl.direnv

            marketplace.irongeek.vscode-env
            #marketplace.yzane.markdown-pdf
            marketplace.yzhang.markdown-all-in-one
          ];

          userSettings = {
            # --- Apparence & Base ---
            "editor.formatOnSave" = true;
            "workbench.iconTheme" = "material-icon-theme";
            "workbench.colorTheme" = "GitHub Dark Default";

            # --- Configuration Nix IDE (Optimisée pour 'nil') ---
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
            "nix.serverSettings" = {
              "nil" = {
                "formatting" = {
                  "command" = [ "alejandra" ];
                };
              };
            };

            # --- Configuration Direnv ---
            # Recharge automatiquement VS Code quand ton .envrc change
            "direnv.restart.automatic" = true;
          };

          keybindings = [
            # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
            {
              key = "shift+cmd+j";
              command = "workbench.action.focusActiveEditorGroup";
              when = "terminalFocus";
            }
          ];
        };
      };
    };
  };
}
