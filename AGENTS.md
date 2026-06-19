# Instructions pour les Agents (nix-config)

Ce dépôt contient la configuration système de Frédéric Lebel pour NixOS, nix-darwin (macOS) et Home-Manager, orchestrée via Nix Flakes.

## Commandes du projet (via `just`)

Pour toute opération, utilise les recettes définies dans le `justfile` :
- `just fmt` : Formater tout le code du projet (via treefmt)
- `just check` : Vérifier la configuration du Flake (`nix flake check`)
- `just switch-mac` : Reconstruire et appliquer la configuration macOS locale (nix-darwin)
- `just deploy <host>` : Déployer la configuration sur un serveur Linux ciblé via Colmena
- `just deploy-all` : Déployer sur tous les serveurs de l'inventaire via Colmena
- `just edit-secret <host>` : Éditer les secrets SOPS d'un hôte spécifique
- `just clean` : Nettoyer les anciennes générations Nix et optimiser le store

> [!IMPORTANT]
> Les Flakes Nix évaluent uniquement les fichiers suivis par Git. Si tu crées ou modifies un fichier non suivi, tu **dois** impérativement lancer `git add <fichier>` (ou `git add .`) avant d'exécuter une commande de build ou d'évaluation (`nix flake check`, `just switch-mac`, etc.).

## Principes d'Architecture & Conception

Toutes les modifications doivent respecter ces principes rigoureux :

### 1. Séparation des Préoccupations (Quoi vs Comment)
La base de code distingue formellement la déclaration d'intention de l'implémentation technique :
- **Les Hôtes (`hosts/`) définissent le "Quoi"** : Ils ne doivent contenir que la configuration spécifique au matériel et l'activation déclarative de fonctionnalités (ex : `my.features.logseq.enable = true;`). Pas de logique complexe.
- **Les Modules (`modules/`) définissent le "Comment"** : C'est ici que réside la logique complexe, l'installation de paquets et la configuration fine des services.
**Règle :** Ne place jamais de logique de configuration complexe directement dans `hosts/`. Crée un module dans `modules/` et expose une option pour l'activer.

### 2. Pattern "Factory" et Inversion de Contrôle
La génération des systèmes est centralisée dans une usine abstraite :
- [nix/lib/helpers.nix](file:///Users/flebel/repositories/nix-config/nix/lib/helpers.nix) expose `mkSystem`, qui gère l'injection uniforme de `home-manager`, `sops-nix` et des `specialArgs`.
- L'inventaire global [nix/lib/inventory.nix](file:///Users/flebel/repositories/nix-config/nix/lib/inventory.nix) est l'unique source de vérité pour la liste des hôtes.
**Règle :** Pour ajouter un hôte, modifie `inventory.nix` et crée son répertoire dans `hosts/`. Ne modifie pas la logique de génération dans `flake.nix` sans discussion préalable sur l'architecture.

### 3. Encapsulation via le Namespace `my`
Pour garantir une isolation propre et éviter les collisions de noms, toutes les options personnalisées sont encapsulées.
**Règle :** Toute nouvelle option (via `lib.mkOption`) ou regroupement logique doit impérativement être préfixé par le namespace `my.` (ex : `my.bundles.laptop`, `my.features.dev.git`).

### 4. Composabilité : Features vs Bundles
L'architecture favorise la composition plutôt que l'héritage profond :
- **Features (`modules/**/features/`)** : Unités fonctionnelles atomiques et indépendantes (un outil, un service).
- **Bundles (`modules/**/bundles/`)** : Profils de haut niveau (ex : `laptop`, `server`) agissant comme des façades pour activer une collection de features.
**Règle :** Ajoute les nouveaux outils comme des *features*. Si cet outil est essentiel à un type de machine, intègre son activation dans le *bundle* correspondant.

### 5. Objet de Contexte (Context Object Pattern)
Les informations transversales sont regroupées dans un objet `myMeta` injecté partout.
- `myMeta` contient les métadonnées de l'hôte (tags, rôles, infos réseau) définies dans `hosts/<host>/host-meta.nix`.
**Règle :** Utilise `config.myMeta` au lieu de coder en dur des valeurs globales dans tes modules pour garantir la portabilité des configurations.

## Limites & Sécurité
- Ne modifie jamais manuellement les fichiers générés (comme `result` ou `.direnv/`).
- Ne commite jamais de secrets ou de clés de chiffrement en clair. Utilise toujours SOPS via le fichier `secrets.yaml` associé à chaque hôte.
