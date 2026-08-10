---
name: add-system-host
description: Guide et modèles pour ajouter une nouvelle machine (hôte macOS ou NixOS) dans la configuration du dépôt.
---

Ce skill détaille les étapes nécessaires pour ajouter une nouvelle machine à la configuration.

## Processus d'ajout d'une machine

### Étape 1 : Créer le dossier de l'hôte

Créez un dossier sous `hosts/<nom-de-la-machine>/`.

### Étape 2 : Créer les fichiers de configuration de base

Dans ce dossier, vous devez créer trois fichiers (ou les copier depuis le dossier `examples/` de ce skill) :

1. `spec.nix` : Spécifications de la machine (OS, architecture, tags, et liste des features et bundles activés).
2. `configuration.nix` : Configuration système principale (Darwin ou NixOS).
3. `home.nix` : Déclarations pour Home-Manager (fichiers utilisateur).

### Étape 3 : Déclarer l'hôte dans le Flake

Modifiez le fichier `flake.nix` à la racine pour ajouter l'hôte dans la variable `hosts` :

```nix
hosts = {
  # ... autres hôtes ...
  <nom-de-la-machine> = import ./hosts/<nom-de-la-machine>/spec.nix;
};
```

### Étape 4 : Déployer et appliquer

- Si c'est un Mac local : `just switch-mac <nom-de-la-machine>`
- Si c'est un serveur NixOS Colmena : `just deploy <nom-de-la-machine>`

## Modèles disponibles

- [spec-darwin.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/add-system-host/examples/spec-darwin.nix)
- [spec-nixos.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/add-system-host/examples/spec-nixos.nix)
- [configuration.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/add-system-host/examples/configuration.nix)
- [home.nix](file:///Users/flebel/repositories/nix-config/.agents/skills/add-system-host/examples/home.nix)
