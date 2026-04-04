set shell := ["bash", "-uc"]

# Variables
flake_path := "."
user       := "flebel"
green      := `tput setaf 2`
reset      := `tput sgr0`

[private]
default:
    @just --list

# DAY 0 : PROVISIONING & BOOTSTRAP (Le socle)

# [Day 0] Installer Determinate Nix (méthode officielle)
[group('day-0')]
[group('nix')]
install-nix:
    @echo "{{green}}❄️  Day 0 (Nix): Installation de Determinate Nix...{{reset}}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# [Day 0] Mettre à jour Determinate Nix
[group('day-0')]
[group('nix')]
update-nix:
    @echo "{{green}}🔄 Day 0 (Nix): Vérification de la mise à jour...{{reset}}"
    @if command -v determinate-nixd > /dev/null; then \
        sudo determinate-nixd upgrade; \
    else \
        echo "determinate-nixd non trouvé. Utilisation de la méthode de réinstallation..."; \
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; \
    fi

# [Day 0] Vérifier l'état de l'installation et les versions
[group('day-0')]
[group('nix')]
status-nix:
    @echo "{{green}}📊 Day 0 (Nix): État du système...{{reset}}"
    @echo "--- Version de Nix ---"
    nix --version
    @echo "--- État de Determinate Nix ---"
    @if command -v determinate-nixd > /dev/null; then \
        determinate-nixd --help | head -n 1; \
        echo "Le service est opérationnel."; \
    else \
        echo "determinate-nixd n'est pas installé ou pas dans le PATH."; \
    fi

# [Day 0] Setup initial du Mac
[group('day-0')]
[group('macos')]
[macos]
setup-mac:
    @echo "{{green}}🍎 Day 0 (Setup): Installation des outils de base sur Mac...{{reset}}"
    xcode-select --install || true
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    command -v nix >/dev/null || just install-nix

# [Day 0] Installation NixOS "from scratch" via nixos-anywhere
[group('day-0')]
install-server host ip:
    @echo "{{green}}💿 Day 0 (Install): Déploiement NixOS sur métal nu ({{host}})...{{reset}}"
    git add .
    nix run github:nix-community/nixos-anywhere -- --build-on remote --flake .#{{host}} root@{{ip}}

# DAY 1 : INITIALISATION & CODE (Le premier lancement)

# [Day 1] Formater tout le projet
[group('day-1')]
fmt:
    @echo "{{green}}🎨 Day 1 (Format): Nettoyage du code...{{reset}}"
    treefmt || nix fmt

# [Day 1] Vérifier la configuration avant le premier push
[group('day-1')]
check:
    @echo "{{green}}🔍 Day 1 (Check): Vérification du Flake...{{reset}}"
    nix flake check --show-trace

# DAY 2 : DEPLOY & COLMENA (Le "Run" quotidien)

# [Day 2] Mettre à jour le Mac local (nix-darwin)
[group('day-2')]
[group('darwin')]
[macos]
switch-mac host=`hostname -s`:
    @echo "{{green}}🍏 Day 2 (Deploy): Mise à jour de {{host}}...{{reset}}"
    git add .
    nom build .#darwinConfigurations.{{host}}.system
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{host}}

# [Day 2] Déployer sur les serveurs Linux ciblés via Colmena
[group('day-2')]
[group('colmena')]
deploy +TARGETS:
    @echo "{{green}}☁️  Day 2 (Deploy): Colmena apply sur {{ TARGETS }}...{{reset}}"
    git add .
    colmena apply --verbose --on {{ TARGETS }} --build-on-target switch

# [Day 2] Déployer sur tous les serveurs Linux définis dans l'inventaire via Colmena
[group('day-2')]
[group('colmena')]
deploy-all:
    @echo "{{green}}☁️  Day 2 (Deploy): Colmena apply sur ...{{reset}}"
    git add .
    colmena apply --verbose --build-on-target switch

# [Day 2] Déployer sur les serveurs Linux ciblés avec reboot via Colmena
[group('day-2')]
[group('colmena')]
deploy-reboot +TARGETS:
    @echo "{{green}}☁️  Day 2 (Deploy): Colmena apply + reboot sur {{ TARGETS }}...{{reset}}"
    git add .
    colmena apply --verbose --on {{ TARGETS }} --build-on-target --reboot

# DAY 2 : SECRETS (Gestion SOPS)

# [Day 2] Éditer les secrets d'un hôte
[group('day-2')]
[group('secrets')]
edit-secret host:
    sops hosts/{{host}}/secrets.yaml

# [Day 2] Rotation des clés (re-chiffrage complet)
[group('day-2')]
[group('secrets')]
rotate-secrets:
    @echo "{{green}}🔄 Day 2 (Secrets): Rotation SOPS...{{reset}}"
    find . -name "secrets.yaml" -exec sops updatekeys {} \;

# DAY 2 : OPS & MAINTENANCE

# [Day 2] Nettoyage profond des profils Nix
[group('day-2')]
[group('ops')]
clean age='7d':
    @echo "{{green}}🧹 Day 2 (Ops): Nettoyage des générations > {{age}}...{{reset}}"
    {{ if os() == "macos" { "nix-collect-garbage -d" } else { "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations " + age + " && nix-collect-garbage -d" } }}
    nix store optimise

# [Day 2] Voir les logs d'un service systemd distant
[group('day-2')]
[group('ops')]
logs host service:
    @echo "{{green}}📋 Day 2 (Ops): Logs de {{service}} sur {{host}}...{{reset}}"
    ssh {{user}}@{{host}}.opval.com "sudo journalctl -u {{service}} -f"

# [Day 2] Mettre à jour une dépendance du Flake
[group('day-2')]
[group('ops')]
update-input input:
    @echo "{{green}}📦 Day 2 (Ops): Update de {{input}}...{{reset}}"
    nix flake lock --update-input {{input}}
