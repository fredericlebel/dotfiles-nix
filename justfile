# Justfile
set shell := ["bash", "-uc"]

# Variables globales
flake_path := "."
user := "flebel"

# Couleur pour les logs
green := `tput setaf 2`
reset := `tput sgr0`

default:
    @just --list

# DÉPLOIEMENT & SYNC

# Tout mettre à jour (Mac local + Serveurs distants)
[confirm]
up: switch deploy

# Mettre à jour le Mac local (Caladan) avec logs améliorés (nom)
switch host='caladan':
    @echo "{{green}}🍏 Mise à jour de {{host}}...{{reset}}"
    git add .
    # Étape 1 : Build
    nom build .#darwinConfigurations.{{host}}.system
    # Étape 2 : Switch (Nécessite sudo pour l'activation !)
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{host}}

# Mettre à jour les serveurs Linux via Colmena
deploy target='ix':
    @echo "{{green}}☁️  Déploiement sur {{target}} via Colmena...{{reset}}"
    git add .
    colmena apply --on {{target}}

# Provisionner un serveur vierge (Disko + NixOS)
install host ip:
    @echo "{{green}}💿 Installation "Day 0" sur {{host}} ({{ip}})...{{reset}}"
    git add .
    nix run github:nix-community/nixos-anywhere -- \
        --build-on-remote \
        --flake .#{{host}} \
        root@{{ip}}

# SÉCURITÉ & SECRETS (SOPS)

# Éditer les secrets d'un hôte (ex: just edit-secret ix)
edit-secret host:
    sops hosts/{{host}}/secrets.yaml

# Pivoter les clés (re-chiffrer tous les secrets si on change de clés)
rotate-secrets:
    @echo "{{green}}🔄 Rotation des secrets SOPS...{{reset}}"
    find . -name "secrets.yaml" -exec sops updatekeys {} \;

# MAINTENANCE & OPS

# Nettoyage profond (Older than 7d)
clean age='7d':
    @echo "{{green}}🧹 Nettoyage des générations de plus de {{age}}...{{reset}}"
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations {{age}}
    nix-collect-garbage -d
    # Optimisation du store (hardlink les fichiers identiques)
    nix store optimise

# Formater tout le projet
fmt:
    treefmt || nix fmt

# Vérifier la config avant de push
check:
    @echo "{{green}}🔍 Vérification du Flake...{{reset}}"
    nix flake check --show-trace

# Mettre à jour une dépendance spécifique (plus sûr que update global)
update-input input:
    nix flake lock --update-input {{input}}

# Voir les logs d'un service systemd distant (ex: just logs ix vaultwarden)
logs host service:
    ssh {{user}}@{{host}}.opval.com "sudo journalctl -u {{service}} -f"

# BOOTSTRAP (Usage unique)

setup-mac:
    @echo "{{green}}🍎 Installation des outils de base...{{reset}}"
    xcode-select --install || true
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    command -v nix >/dev/null || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
