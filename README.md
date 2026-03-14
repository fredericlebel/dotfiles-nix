# ❄️ Dotfiles & Nix Configurations

[![Nix CI](https://github.com/fredericlebel/dotfiles-nix/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/fredericlebel/dotfiles-nix/actions/workflows/ci.yml)
[![Built with Nix](https://img.shields.io/badge/Built_with-Nix-5277C3.svg?logo=nixos&logoColor=white)](https://builtwithnix.org)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-41439a?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)

Ce dépôt contient l'infrastructure déclarative de mes machines, gérée entièrement via **Nix Flakes**, **NixOS**, et **nix-darwin**. Maintenu par Frédéric Lebel.

## 📂 Structure du dépôt

```text
.
├── flake.nix             # Point d'entrée principal (définition des inputs et outputs)
├── hosts/
│   ├── ix/               # Configuration spécifique à NixOS (hardware, services)
│   └── caladan/          # Configuration spécifique à macOS (Homebrew, system defaults)
├── modules/              # Modules Nix réutilisables à travers les machines
├── nix/dev/              # DevShells (environnements de développement locaux)
└── .github/workflows/    # Pipeline CI/CD (validation, formatage, dry-run)
```

## Cycle de vie : day 0, 1, 2

## 🏗️ Day 0 : Provisioning & Bootstrap (Le Socle)
Le Day 0 concerne tout ce qui doit être fait avant que Nix ne soit fonctionnel ou que le système ne soit déployé. C'est l'étape de préparation brute.

Actions : Installation de l'installateur Nix (Determinate Systems), configuration initiale du Mac (Xcode, Homebrew), ou déploiement initial de NixOS sur un serveur vierge via nixos-anywhere.

Objectif : Passer d'une machine "nue" à un système capable de comprendre les Flakes Nix.

## 🏁 Day 1 : Initialisation & Code (Le premier lancement)
Le Day 1 se concentre sur la mise en conformité du projet et les premières vérifications. C'est le pont entre l'installation et l'exploitation.

Actions : Formatage du code (fmt), vérification de la syntaxe du Flake (check), et s'assurer que l'environnement de développement est sain.

Objectif : Garantir que la configuration est valide et prête à être appliquée.

## 🛠️ Day 2 : Operations & Maintenance (Le "Run" quotidien)
Le Day 2 représente 99 % de la vie du projet. C'est l'étape de maintenance continue, de mise à jour et de surveillance.

Actions :

Deploy : Appliquer les changements sur le Mac local ou les serveurs distants via Colmena.

Secrets : Gestion et rotation des clés de chiffrement (SOPS).

Maintenance : Nettoyage du cache Nix (Garbage Collection), mise à jour des entrées du Flake (flake update), et consultation des logs.

Objectif : Maintenir le système à jour, sécurisé et performant sur le long terme.


## Installation

> curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
info: downloading installer
 INFO nix-installer v3.15.1
`nix-installer` needs to run as `root`, attempting to escalate now via `sudo`...
Password:
 INFO nix-installer v3.15.1
 INFO For a more robust Nix installation, use the Determinate package for macOS: https://dtr.mn/determinate-nix
Nix install plan (v3.15.1)
Planner: macos (with default settings)

Planned actions:
* Install Determinate Nixd
* Create an encrypted APFS volume `Nix Store` for Nix on `disk3` and add it to `/etc/fstab` mounting on `/nix`
* Extract the bundled Nix (originally from /nix/store/hwxncwfxh9sndswqgjbiv7ssjx57ikny-nix-binary-tarball-3.15.1/nix-3.15.1-aarch64-darwin.tar.xz) to `/nix/temp-install-dir`
* Create a directory tree in `/nix`
* Synchronize /nix/var ownership
* Move the downloaded Nix into `/nix`
* Synchronize /nix/store ownership
* Create build users (UID 351-382) and group (GID 350)
* Configure Time Machine exclusions
* Setup the default Nix profile
* Place the Nix configuration in `/etc/nix/nix.conf`
* Configure the shell profiles
* Configuring zsh to support using Nix in non-interactive shells
* Create a `launchctl` plist to put Nix into your PATH
* Configure the Determinate Nix daemon
* Remove directory `/nix/temp-install-dir`


Proceed? ([Y]es/[n]o/[e]xplain): y
 INFO Step: Install Determinate Nixd
 INFO Step: Create an encrypted APFS volume `Nix Store` for Nix on `disk3` and add it to `/etc/fstab` mounting on `/nix`
 INFO Step: Provision Nix
 INFO Step: Create build users (UID 351-382) and group (GID 350)
 INFO Step: Configure Time Machine exclusions
 INFO Step: Configure Nix
 INFO Step: Configuring zsh to support using Nix in non-interactive shells
 INFO Step: Create a `launchctl` plist to put Nix into your PATH
 INFO Step: Configure the Determinate Nix daemon
 INFO Step: Remove directory `/nix/temp-install-dir`
Nix was installed successfully!
To get started using Nix, open a new shell or run `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
