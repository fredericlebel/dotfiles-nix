# Instructions Architecturales pour Gemini CLI : nix-config

Ce dépôt suit des principes de conception logicielle rigoureux inspirés par Martin Fowler (Separation of Concerns, Factory Pattern, Encapsulation). En tant qu'assistant (Gemini CLI), tu **dois** respecter ces principes lors de toute modification ou analyse.

## 1. Séparation des Préoccupations (Le "Quoi" vs le "Comment")
La base de code distingue formellement la déclaration d'intention de l'implémentation technique.

*   **Les Hôtes (`hosts/`) définissent le "Quoi"** : Ils ne doivent contenir que de la configuration spécifique au matériel et l'activation déclarative de fonctionnalités (ex: `my.features.logseq.enable = true`).
*   **Les Modules (`modules/`) définissent le "Comment"** : C'est ici que réside la logique complexe, l'installation de paquets et la configuration fine des services.

**Règle :** Ne place jamais de logique de configuration complexe directement dans `hosts/`. Crée un module dans `modules/` et expose une option pour l'activer.

## 2. Pattern "Factory" et Inversion de Contrôle
La génération des systèmes est centralisée dans une usine (`Factory`) abstraite.
*   `nix/lib/helpers.nix` expose `mkSystem`, qui gère l'injection uniforme de `home-manager`, `sops-nix` et des `specialArgs`.
*   L'inventaire global (`nix/lib/inventory.nix`) est l'unique source de vérité pour la liste des hôtes.

**Règle :** Pour ajouter un hôte, modifie `inventory.nix` et crée son répertoire dans `hosts/`. Ne modifie pas la logique de génération dans `flake.nix` sans discussion préalable sur l'architecture.

## 3. Encapsulation via le Namespace `my`
Pour garantir une isolation propre et éviter les collisions de noms, toutes les options personnalisées sont encapsulées.

**Règle :** Toute nouvelle option (via `lib.mkOption`) ou regroupement logique doit impérativement être préfixé par le namespace `my.` (ex: `my.bundles.laptop`, `my.features.dev.git`).

## 4. Composabilité : Features vs Bundles
L'architecture favorise la composition à la "Lego" plutôt que l'héritage profond.
*   **Features (`modules/**/features/`)** : Unités fonctionnelles atomiques et indépendantes (un outil, un service).
*   **Bundles (`modules/**/bundles/`)** : Profils de haut niveau (ex: `laptop`, `server`) qui agissent comme des façades pour activer une collection de features.

**Règle :** Ajoute les nouveaux outils comme des *features*. Si cet outil est essentiel à un type de machine, intègre son activation dans le *bundle* correspondant.

## 5. Objet de Contexte (Context Object Pattern)
Les informations transversales sont regroupées dans un objet `myMeta` injecté partout.
*   `myMeta` contient les métadonnées de l'hôte (tags, rôles, infos réseau) définies dans `hosts/<host>/host-meta.nix`.

**Règle :** Utilise `config.myMeta` au lieu de coder en dur des valeurs globales dans tes modules pour garantir la portabilité des configurations.
