# Contexte Local : Modules Nix

Tu es dans le répertoire de création des modules (`modules/`).

## Règles de développement :
1.  **Granularité** : Préfère toujours créer des "features" atomiques (ex: `modules/home/features/cli/bat/default.nix`) plutôt que de surcharger un "bundle".
2.  **Options** : Toute feature DOIT déclarer ses options via `lib.mkOption` sous le namespace `my.features.<nom>`.
3.  **Packages** : N'ajoute pas de paquets globalement si la feature n'est pas activée.
4.  **Meta** : Utilise `config.myMeta` si tu as besoin de variables globales à l'hôte.
