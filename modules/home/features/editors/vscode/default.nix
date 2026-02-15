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
  withExtension =
    ext: settings:
    lib.optionalAttrs (builtins.elem ext config.programs.vscode.profiles.default.extensions) settings;
in
{
  options.my.features.editors.vscode = {
    enable = lib.mkEnableOption "vscode avec intégration Zsh, Nix (LSP) et Direnv";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      nil
      nixfmt
    ];

    programs.vscode = {
      enable = true;

      profiles = {
        default = {
          extensions = [
            # --- Langages & Formatage ---
            marketplace.jnoortheen.nix-ide
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
            marketplace.ms-python.vscode-python-envs

            # --- AI ---
            marketplace.google.geminicodeassist

            # --- Git ---
            marketplace.github.github-vscode-theme
            marketplace.github.remotehub
            marketplace.github.vscode-github-actions
            marketplace.github.vscode-pull-request-github
            marketplace.ms-vscode.azure-repos

            # --- Utilitaires ---
            marketplace.pkief.material-icon-theme
            marketplace.signageos.signageos-vscode-sops
            marketplace.mkhl.direnv
            marketplace.irongeek.vscode-env
            marketplace.yzhang.markdown-all-in-one
          ];

          keybindings = [
            {
              key = "shift+cmd+j";
              command = "workbench.action.focusActiveEditorGroup";
              when = "terminalFocus";
            }
          ];

          userSettings = lib.mkMerge [
            {
              "editor.formatOnSave" = true;
              "workbench.iconTheme" = "material-icon-theme";
              "workbench.colorTheme" = "GitHub Dark Default";
              "direnv.restart.automatic" = true;
            }

            (withExtension marketplace.jnoortheen.nix-ide {
              "[nix]" = {
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nil";
              "nix.serverSettings" = {
                "nil" = {
                  "formatting" = {
                    "command" = [ "nixfmt" ];
                  };
                };
              };
            })

            (withExtension marketplace.ms-python.python {
              "python.languageServer" = "Pylance";
            })
          ];
        };
      };
    };
  };
}
