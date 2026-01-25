{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.vscode;
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
  options.my.features.vscode = {
    enable = lib.mkEnableOption "vscode avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;

      extensions = [
        # --- Langages & Formatage ---
        marketplace.bbenoist.nix
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
        marketplace.irongeek.vscode-env
        #marketplace.yzane.markdown-pdf
        marketplace.yzhang.markdown-all-in-one
      ];

      userSettings = {
        # This property will be used to generate settings.json:
        # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
        "editor.formatOnSave" = true;
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.colorTheme" = "GitHub Dark Default";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
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
}
