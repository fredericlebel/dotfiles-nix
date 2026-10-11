{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.features.ai.agent-skills;

  # Répertoire racine où AGY découvre globalement les skills
  skillsTargetDir = ".gemini/config/skills";

  # Fonction helper pour générer les fichiers home.file pour une source donnée
  mkSkillEntries =
    {
      sourceRoot,
      subDir ? "skills",
      targets ? [ ],
    }:
    let
      skillsPath = if subDir != "" then "${sourceRoot}/${subDir}" else "${sourceRoot}";
      allSkills =
        if builtins.pathExists skillsPath then
          builtins.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsPath))
        else
          [ ];
      selectedSkills = if targets == [ ] then allSkills else lib.intersectLists targets allSkills;
    in
    lib.listToAttrs (
      map (skillName: {
        name = "${skillsTargetDir}/${skillName}";
        value = {
          source = "${skillsPath}/${skillName}";
          recursive = true;
        };
      }) selectedSkills
    );

  # Entrées pour Anthropic
  anthropicEntries =
    if cfg.sources.anthropic.enable && (inputs ? anthropic-agent-skills) then
      mkSkillEntries {
        sourceRoot = inputs.anthropic-agent-skills;
        subDir = "skills";
        targets = cfg.sources.anthropic.targets;
      }
    else
      { };

  # Entrées pour les sources additionnelles futures
  customEntries = lib.concatMapAttrs (
    _: srcCfg:
    lib.mkIf srcCfg.enable (mkSkillEntries {
      sourceRoot = srcCfg.src;
      inherit (srcCfg) subDir;
      inherit (srcCfg) targets;
    })
  ) cfg.customSources;

in
{
  options.my.features.ai.agent-skills = {
    enable = lib.mkEnableOption "Gestion reproductible et déclarative des Agent Skills dans AGY";

    enableNodejs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Inclure Node.js dans l'environnement pour le runtime des scripts de skills et npx skills.";
    };

    sources = {
      anthropic = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Activer les skills du dépôt anthropics/skills.";
        };
        targets = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Liste des skills à importer (vide pour tous les skills du dépôt).";
        };
      };
    };

    customSources = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Activer cette source de skills";
            src = lib.mkOption {
              type = lib.types.path;
              description = "Chemin ou flake input de la source";
            };
            subDir = lib.mkOption {
              type = lib.types.str;
              default = "skills";
              description = "Sous-dossier contenant les skills dans la source";
            };
            targets = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Liste de skills spécifiques (vide pour tous)";
            };
          };
        }
      );
      default = { };
      description = "Dépôts ou dossiers additionnels d'Agent Skills";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals cfg.enableNodejs [
      pkgs.nodejs_22
    ];

    # Projection immuable dans ~/.gemini/config/skills/
    home.file = anthropicEntries // customEntries;
  };
}
