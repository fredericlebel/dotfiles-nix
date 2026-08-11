---
name: troubleshoot-nix-eval
description: Guide de diagnostic et résolution des erreurs d'évaluation Nix et de déploiements Colmena.
---

Ce skill fournit des clés de diagnostic pour résoudre rapidement les erreurs d'évaluation du Flake Nix.

## Erreurs d'évaluation Nix courantes

### 1. Fichier Nix non détecté ou ignoré par Flakes

- **Symptôme** : Nix prétend qu'un fichier ou module n'existe pas alors que vous venez de le créer.
- **Cause** : Les Flakes Nix évaluent uniquement les fichiers indexés par Git.
- **Résolution** : Ajoutez impérativement le fichier à Git :
    ```bash
    git add <chemin-du-fichier>
    ```

### 2. Récursion infinie ("infinite recursion encountered")

- **Symptôme** : L'évaluation plante avec un message mentionnant une récursion infinie.
- **Cause** : Un module s'auto-importe, ou l'appel à un argument (ex: `config` ou `pkgs`) crée une dépendance circulaire dans la logique.
- **Résolution** :
    - Utilisez `--show-trace` pour remonter à l'option fautive : `just check --show-trace`.
    - Vérifiez les imports dans le fichier d'hôte ou les modules.

### 3. Option inconnue ("The option ... does not exist")

- **Symptôme** : Une option utilisée dans une configuration n'est pas trouvée.
- **Cause** : Typo dans le nom de l'option (ex: `my.feature.xxx` au lieu de `my.features.xxx`) ou le module déclarant l'option n'a pas été importé dans `os/hosts/<host>/configuration.nix`.
- **Résolution** :
    - Vérifiez l'orthographe exacte sous `options.my.features.<nom>`.
    - Assurez-vous que le module contenant la déclaration de l'option est importé dans la liste `imports` du fichier `configuration.nix` de l'hôte.

## Problèmes de déploiement (Colmena)

### 1. Échec d'authentification SSH

- **Symptôme** : Colmena n'arrive pas à se connecter au serveur cible.
- **Résolution** :
    - Vérifiez que votre clé SSH est présente dans votre agent SSH local (`ssh-add -l`).
    - Assurez-vous que l'IP ou le nom de domaine de la machine est correct et accessible (`ping ix.opval.com`).

### 2. Problème de décryptage SOPS sur la machine cible

- **Symptôme** : Le build réussit mais l'activation échoue car un fichier secret ne peut pas être déchiffré.
- **Résolution** :
    - Assurez-vous que la clé SSH privée de la machine cible (ex: `/etc/ssh/ssh_host_ed25519_key`) est celle correspondant à la clé publique configurée pour cet hôte dans `.sops.yaml`.
