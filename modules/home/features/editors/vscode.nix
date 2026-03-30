{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.editors.vscode;
  marketplace =
    inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace;

  withExtension =
    ext: settings:
    lib.optionalAttrs (builtins.elem ext config.programs.vscode.profiles.default.extensions) settings;
in
{
  options.my.features.editors.vscode = {
    enable = lib.mkEnableOption "vscode avec intégration Zsh, Nix (LSP) et Direnv";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixd
      nixfmt
    ];

    my.registry.dockApps = lib.mkIf pkgs.stdenv.isDarwin [
      "/Users/${config.home.username}/Applications/Home Manager Apps/Visual Studio Code.app"
    ];

    programs.vscode = {
      enable = true;

      profiles = {
        default = {
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;

          extensions = [
            # Langages & Formatage
            marketplace.jnoortheen.nix-ide
            marketplace.rust-lang.rust-analyzer
            marketplace.tamasfe.even-better-toml
            marketplace.redhat.vscode-yaml
            marketplace.bluebrown.yamlfmt
            marketplace.blueglassblock.better-json5
            marketplace.wholroyd.jinja
            marketplace.editorconfig.editorconfig

            # Python
            marketplace.ms-python.python
            marketplace.ms-python.debugpy
            marketplace.ms-python.vscode-python-envs

            # AI
            # marketplace.google.geminicodeassist

            # Git
            marketplace.github.github-vscode-theme
            marketplace.github.remotehub
            marketplace.github.vscode-github-actions
            marketplace.github.vscode-pull-request-github
            marketplace.ms-vscode.azure-repos

            # Utilitaires
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
              # Ramène le focus sur l'éditeur quand on est dans le terminal
              when = "terminalFocus";
            }
          ];

          userSettings = lib.mkMerge [
            {
              # APPARENCE ET TYPOGRAPHIE

              # Police avec support des ligatures et icônes
              "editor.fontFamily" = "FiraCode Nerd Font Mono";

              # Taille du texte confortable
              "editor.fontSize" = 13;

              # Lignes verticales pour respecter les standards de longueur de code
              "editor.rulers" = [
                80
                120
              ];

              # ERGONOMIE ET NAVIGATION (ÉDITEUR)

              # Masque la minimap à droite pour gagner de la place
              "editor.minimap.enabled" = false;

              # Numérotation relative, idéal pour les sauts de lignes au clavier (style Vim)
              "editor.lineNumbers" = "relative";

              # Surligne toute la ligne où se trouve le curseur pour un repérage rapide
              "editor.renderLineHighlight" = "all";

              # N'affiche les symboles d'espace qu'à la fin des lignes (espaces inutiles)
              "editor.renderWhitespace" = "trailing";

              # Colorise les paires de () et {} de la même couleur
              "editor.bracketPairColorization.enabled" = true;

              # Trace une ligne verticale entre l'ouverture et la fermeture des blocs
              "editor.guides.bracketPairs" = true;

              # Affiche les types inférés, mais reste caché tant qu'on n'appuie pas sur Ctrl/Cmd
              "editor.inlayHints.enabled" = "onUnlessPressed";

              # Permet de scroller en dessous de la dernière ligne de code
              "editor.scrollBeyondLastLine" = true;

              # Défilement fluide (moins saccadé)
              "editor.smoothScrolling" = true;

              # Effet de fondu sur le clignotement du curseur
              "editor.cursorBlinking" = "smooth";

              # Animation fluide quand le curseur change de position
              "editor.cursorSmoothCaretAnimation" = "on";

              # HYGIÈNE DES FICHIERS ET SAUVEGARDE
              # Applique automatiquement le formateur configuré à l'enregistrement
              "editor.formatOnSave" = true;

              # Nettoie les espaces invisibles en fin de ligne à la sauvegarde
              "files.trimTrailingWhitespace" = true;

              # Ajoute toujours une ligne vide à la fin du fichier (standard POSIX)
              "files.insertFinalNewline" = true;

              # Supprime les lignes vides en trop à la fin du fichier
              "files.trimFinalNewlines" = true;

              # WORKBENCH (INTERFACE ET COMPORTEMENT)
              # Thème d'icônes pour l'explorateur de fichiers
              "workbench.iconTheme" = "material-icon-theme";

              # Thème global de l'éditeur
              "workbench.colorTheme" = "GitHub Dark Default";

              # Ouvre toujours de vrais onglets (désactive le mode aperçu en italique)
              "workbench.editor.enablePreview" = false;

              # Bloque les pop-ups agaçants recommandant des extensions
              "extensions.ignoreRecommendations" = true;

              # Met à jour les extensions en arrière-plan
              "extensions.autoUpdate" = true;

              # Empêche VS Code de se mettre à jour lui-même (laissé à Nix)
              "update.mode" = "none";

              # EXPLORATEUR ET RECHERCHE (FILTRES)
              "search.exclude" = {
                # Exclut l'historique Git des résultats de recherche
                "**/.git" = true;
                # Exclut le cache d'environnement Direnv
                "**/.direnv" = true;
                # Exclut les environnements virtuels Python locaux
                "**/.venv" = true;
                # Exclut les dossiers de compilation (ex: Rust/Cargo)
                "**/target" = true;
                # Exclut les dossiers de dépendances JS
                "**/node_modules" = true;
              };

              "files.exclude" = {
                # Masque le dossier Git de l'arborescence à gauche
                "**/.git" = true;
                # Masque les fichiers systèmes de macOS
                "**/.DS_Store" = true;
              };
            }

            # CONFIGURATIONS LIÉES AUX EXTENSIONS
            (withExtension marketplace.mkhl.direnv {
              # Recharge automatiquement l'environnement quand le .envrc change
              "direnv.restart.automatic" = true;
              # Rend Direnv silencieux pour éviter le spam de notifications
              "direnv.showNotifications" = false;
            })

            (withExtension marketplace.jnoortheen.nix-ide {
              "[nix]" = {
                # Définit l'extension Nix comme formateur par défaut pour les fichiers .nix
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };

              # Active le serveur de langage Nix pour l'autocomplétion
              "nix.enableLanguageServer" = true;

              # Spécifie d'utiliser `nixd` comme serveur de langage
              "nix.serverPath" = "nixd";

              "nix.serverSettings" = {
                "nixd" = {
                  "formatting" = {
                    # Utilise `nixfmt` pour le formatage du code Nix
                    "command" = [ "nixfmt" ];
                  };
                };
              };
            })

            (withExtension marketplace.ms-python.python {
              # Utilise Pylance (très rapide et précis) pour l'analyse du code Python
              "python.languageServer" = "Pylance";
            })
          ];
        };
      };
    };
  };
}
