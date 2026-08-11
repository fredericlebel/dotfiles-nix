# Instructions pour les Agents (nix-config)

Ce dépôt contient la configuration système de Frédéric Lebel pour NixOS, nix-darwin (macOS) et Home-Manager, orchestrée via Nix Flakes.

## 1. Workflow Git, Rebase & Pull Requests (PR)

Avant toute action modifiant le code du dépôt, respecte rigoureusement ce flux de travail :

### Préparation

- Bascule systématiquement sur la branche par défaut et mets-la à jour en effectuant obligatoirement un rebase :
    ```bash
    git checkout main && git pull --rebase
    ```

### Branches de travail

- Ne commite jamais directement sur `main`.
- Crée une nouvelle branche en utilisant le préfixe correspondant au type de modification :
    - `feature/<nom>` : Nouvelle fonctionnalité, ajout d'un package, configuration d'un nouvel hôte.
    - `bugfix/<nom>` : Correction d'une erreur d'évaluation Nix ou d'un bug de configuration.
    - `hotfix/<nom>` : Correction critique devant être appliquée rapidement.
    - `chore/<nom>` : Tâches de maintenance (mise à jour du lockfile, formatage, refactoring).

### Conventions de Commit (Conventional Commits)

- Effectue des commits atomiques (une seule modification logique par commit).
- Utilise des messages clairs au présent en respectant le format `type(scope): message` :
    - `feat(os/modules/nom): message` (ex: `feat(os/modules/zsh): activation de l'autocomplétion`)
    - `fix(os/hosts/nom): message` (ex: `fix(os/hosts/darwin): correction du chemin home-manager`)
    - `chore(deps): message` (ex: `chore(flake): mise à jour du input nixpkgs`)
    - `docs: message` (ex: `docs(agents): ajout des règles git workflow`)

### Publication et création de Pull Requests

- Ne pousse jamais directement tes modifications sur `main`.
- Une fois les commits effectués, pousse la branche de travail :
    ```bash
    git push -u origin HEAD
    ```
- Crée systématiquement une Pull Request (PR) sur GitHub. Utilise la CLI GitHub (`gh`) si elle est disponible et configurée. Privilégie la rédaction d'un titre et d'une description clairs (via les options `--title` et `--body`) décrivant précisément les changements, plutôt que d'utiliser uniquement `--fill` (qui peut laisser la description vide) :
    ```bash
    gh pr create --title "type(scope): titre explicite" --body "Description détaillée des changements"
    ```
- Si la CLI `gh` n'est pas disponible ou non connectée, demande poliment au utilisateur de créer la PR et fournis-lui le lien pour le faire.

---

## 2. Commandes du projet (via `just`)

Pour toute opération de formatage, de build, ou de déploiement, utilise **exclusivement** les recettes définies dans le `justfile` :

- `just fmt` : Formater tout le code du projet (via treefmt)
- `just check` : Vérifier la configuration du Flake (`nix flake check`)
- `just switch-mac` : Reconstruire et appliquer la configuration macOS locale (nix-darwin)
- `just deploy <host>` : Déployer la configuration sur un serveur Linux ciblé via Colmena
- `just deploy-all` : Déployer sur tous les serveurs de l'inventaire via Colmena
- `just edit-secret <host>` : Éditer les secrets SOPS d'un hôte spécifique
- `just clean` : Nettoyer les anciennes générations Nix et optimiser le store

> [!IMPORTANT]
> Les Flakes Nix évaluent uniquement les fichiers suivis par Git. Si tu crées ou modifies un fichier non suivi, tu **dois** impérativement lancer `git add <fichier>` (ou `git add .`) avant d'exécuter une commande de build ou d'évaluation (`nix flake check`, `just switch-mac`, etc.).

---

## 3. Principes d'Architecture & Conception

Toutes les modifications de code doivent respecter ces principes :

### A. Séparation des Préoccupations (Quoi vs Comment)

- **Les Hôtes (`os/hosts/`) définissent le "Quoi"** : Ils ne doivent contenir que la configuration spécifique au matériel et l'activation déclarative de fonctionnalités (ex : `my.features.logseq.enable = true;`). Pas de logique complexe.
- **Les Modules (`os/modules/`) définissent le "Comment"** : C'est ici que réside la logique complexe, l'installation de paquets et la configuration fine des services.

* **Règle** : Ne place jamais de logique de configuration complexe directement dans `os/hosts/`. Crée un module dans `os/modules/` et expose une option pour l'activer.

### B. Pattern "Factory" et Inversion de Contrôle

- La génération des systèmes est centralisée dans une usine abstraite.
- `nix/lib/helpers.nix` expose `mkSystem`, qui gère l'injection de `home-manager`, `sops-nix`, et des `specialArgs`.
- L'inventaire global `os/hosts/default.nix` est l'unique source de vérité pour la liste des hôtes (Domain-Driven Design).

* **Règle** : Pour ajouter un hôte, modifie `os/hosts/default.nix` et crée son répertoire dans `os/hosts/`. Ne modifie pas la logique de génération dans `flake.nix` sans discussion préalable.

### C. Encapsulation via le Namespace `my`

- **Règle** : Toute nouvelle option (via `lib.mkOption`) ou regroupement logique doit impérativement être préfixé par le namespace `my.` (ex : `my.bundles.laptop`, `my.features.dev.git`).

### D. Composabilité : Features vs Bundles

- **Features (`modules/**/features/`)\*\* : Unités fonctionnelles atomiques et indépendantes (un outil, un service).
- **Bundles (`modules/**/bundles/`)** : Profils de haut niveau (ex : `laptop`, `server`) agissant comme des façades pour activer une collection de features.

* **Règle** : Ajoute les nouveaux outils comme des _features_. Si cet outil est essentiel à un type de machine, intègre son activation dans le _bundle_ correspondant.

### E. Objet de Contexte (Context Object Pattern)

- Les informations transversales sont regroupées dans un objet `myMeta` injecté partout.

* **Règle** : Utilise `config.myMeta` au lieu de coder en dur des valeurs globales dans tes modules pour garantir la portabilité des configurations.

---

## 4. Limites & Sécurité

- Ne modifie jamais manuellement les fichiers générés (comme `result` ou `.direnv/`).
- Ne commite jamais de secrets ou de clés de chiffrement en clair. Utilise toujours SOPS via le fichier `secrets.yaml` associé à chaque hôte.
