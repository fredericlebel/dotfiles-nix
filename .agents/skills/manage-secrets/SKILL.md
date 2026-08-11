---
name: manage-secrets
description: Guide pour la gestion et l'intégration des secrets chiffrés avec SOPS et sops-nix dans les configurations d'hôtes.
---

Ce skill détaille les procédures pour manipuler et déclarer des secrets de manière sécurisée.

## Architecture SOPS dans le Dépôt

Les secrets sont chiffrés avec SOPS et stockés dans le répertoire [os/secrets/](file:///Users/flebel/repositories/nix-config/os/secrets) sous forme de fichiers `<host>.yaml` ou de fichiers communs (ex: `vaultwarden.yaml`).
Les clés publiques de chiffrement d'âge (Age) et les règles d'attribution des clés sont définies dans le fichier de configuration [.sops.yaml](file:///Users/flebel/repositories/nix-config/.sops.yaml).

## Procédures courantes

### 1. Éditer ou ajouter un secret

Pour modifier les secrets d'un hôte spécifique :

```bash
sops os/secrets/<host>.yaml
```

_(Alternative via just si applicable : `just edit-secret <host>`)_

### 2. Déclarer un secret dans la configuration Nix d'un hôte (NixOS)

1. Assurez-vous que le module `sops-nix` est importé (généralement géré de manière globale par `mkSystem`).
2. Déclarez le secret dans le fichier `configuration.nix` de l'hôte :
    ```nix
    sops.secrets.mon-secret = {
      # Optionnel : définir le propriétaire du fichier décrypté
      owner = "nom-utilisateur";
    };
    ```
3. Pour utiliser le chemin du secret décrypté dans un service (ex: pour configurer un mot de passe) :
    ```nix
    config.sops.secrets.mon-secret.path
    ```

### 3. Déclarer un secret pour Home-Manager

Si le secret est nécessaire au niveau utilisateur :

```nix
sops.secrets.mon-secret = {
  # Pour Home-Manager, le chemin par défaut est souvent sous $HOME/.config/sops-nix/secrets/
};
```

### 4. Rotation et mise à jour des clés

Si vous ajoutez un nouvel hôte ou changez sa clé publique, mettez à jour `.sops.yaml` puis lancez :

```bash
just rotate-secrets
```
