# ❄️ Dotfiles & Nix Configurations

[![Nix CI](https://github.com/fredericlebel/dotfiles-nix/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/fredericlebel/dotfiles-nix/actions/workflows/ci.yml)
[![Built with Nix](https://img.shields.io/badge/Built_with-Nix-5277C3.svg?logo=nixos&logoColor=white)](https://builtwithnix.org)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-41439a?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%23FFDA18.svg?logo=opentofu&logoColor=black)](https://opentofu.org/)
[![Just](https://img.shields.io/badge/Just-Command_Runner-black)](https://just.systems/)
[![SOPS](https://img.shields.io/badge/Secrets-SOPS-orange)](https://github.com/getsops/sops)

Ce dépôt contient l'infrastructure déclarative de mes machines et de mon réseau, gérée entièrement via **Nix Flakes**, **NixOS**, **nix-darwin** et **OpenTofu**. Maintenu par Frédéric Lebel.

## 📂 Structure du dépôt

```text
.
├── flake.nix             # Point d'entrée principal (définition des inputs et outputs)
├── os/                   # La couche Système & Configuration (Nix)
│   ├── hosts/            # Configuration spécifique aux machines
│   │   ├── ix/           # Serveur NixOS (hardware, services)
│   │   ├── ecaz/         # Serveur NixOS (base de données, infra)
│   │   └── caladan/      # Hôte macOS (Homebrew, system defaults)
│   ├── modules/          # Modules Nix réutilisables à travers les machines
│   ├── nix/              # Librairie (helpers) et DevShells
│   ├── secrets/          # Secrets chiffrés via SOPS
│   └── users/            # Configurations des utilisateurs
├── infrastructure/       # La couche Infrastructure (OpenTofu pour GitHub, Tailscale, etc.)
└── .github/workflows/    # Pipeline CI/CD (validation, formatage, dry-run)
```

## 🚀 Installation Initiale

Si la machine est vierge, installez le gestionnaire de paquets Nix via l'installateur de Determinate Systems, puis clonez ce dépôt :

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
git clone https://github.com/fredericlebel/dotfiles-nix.git ~/.dotfiles
cd ~/.dotfiles
```

Alternativement, utilisez le command runner `just` si disponible : `just install-nix`.

## 🛠️ Commandes Principales (`just`)

Le dépôt utilise [`just`](https://just.systems/) comme interface unique d'orchestration. Tapez simplement `just` pour lister toutes les commandes disponibles.

**Formatage et Validation**

- `just fmt` : Formater tout le code Nix et Terraform du projet.
- `just check` : Valider la configuration du Flake localement.

**Déploiement Système (Nix)**

- `just switch-mac` : Reconstruire et appliquer la configuration macOS locale.
- `just deploy <hôte>` : Déployer la configuration sur un serveur distant via Colmena.
- `just deploy-all` : Déployer sur l'ensemble de l'inventaire.

**Infrastructure as Code (OpenTofu)**

- `just tofu-plan <layer>` : Prévisualiser les changements d'infrastructure (ex: `00-github`).
- `just tofu-apply <layer>` : Appliquer l'infrastructure (les secrets SOPS sont injectés automatiquement).

**Sécurité et Secrets**

- `just edit-secret <hôte>` : Éditer de façon sécurisée le fichier `secrets.yaml` d'un hôte.
- `just rotate-secrets` : Faire une rotation et re-chiffrer tous les secrets.

## 🔄 Cycle de vie : Day 0, 1, 2

- **Day 0 (Le Socle) :** Installation de l'installateur Nix, configuration initiale du Mac, ou déploiement initial de NixOS sur un serveur vierge via `nixos-anywhere`. L'objectif est de passer d'une machine "nue" à un système capable de comprendre les Flakes Nix.
- **Day 1 (Le premier lancement) :** Mise en conformité du projet (`just fmt`), vérification de la syntaxe du Flake (`just check`), et validation que l'environnement de développement est sain.
- **Day 2 (Le "Run" quotidien) :** Maintenance continue (Garbage Collection via `just clean`), mise à jour des dépendances (`just update-input`), déploiement des changements (`just deploy`), et application de l'infrastructure via OpenTofu.
