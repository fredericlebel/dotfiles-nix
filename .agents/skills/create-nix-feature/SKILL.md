---
name: create-nix-feature
description: Aide à concevoir, structurer et générer une nouvelle fonctionnalité (feature) Nix ou Home-manager en respectant les standards du dépôt.
---

Ce skill fournit des instructions et des modèles pour ajouter un nouveau module sous forme de `feature` dans `modules/**/features/`.

## Architecture de Feature
Toutes les options personnalisées doivent résider sous le namespace `my.features.<nom>`.
Le fichier doit suivre la structure :
1. Arguments de la fonction : `{ config, lib, pkgs, ... }`
2. Block `let` définissant un alias court pour la configuration : `cfg = config.my.features.<nom>;`
3. Déclaration des options (`options.my.features.<nom>`) avec `lib.mkEnableOption` et des options additionnelles si nécessaire.
4. Block de configuration conditionnel : `config = lib.mkIf cfg.enable { ... };`.

## Exemples disponibles
* [feature-template.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/create-nix-feature/examples/feature-template.nix) : Un squelette de feature système standard.
* [home-manager-template.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/create-nix-feature/examples/home-manager-template.nix) : Un squelette spécifique pour une feature home-manager (fichiers de conf utilisateur, packages utilisateur).
