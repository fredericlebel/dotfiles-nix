default:
    @just --list

# Installer Nix et Homebrew (avec vérification de présence)
bootstrap:
    @command -v nix >/dev/null || curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    @command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Nettoyer les vieilles générations et le garbage collector
clean age='7d':
    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations {{age}}
    nix-collect-garbage -d

# Déploiement macOS (Darwin) - ex: just darwin caladan
darwin host:
    nix run nix-darwin#darwin-rebuild -- switch --flake .#{{host}}

# Déploiement NixOS à distance - ex: just nixos ix
nixos host:
    nix run nixpkgs#nixos-rebuild -- switch \
        --flake .#{{host}} \
        --target-host flebel@{{host}}.opval.com \
        --build-host flebel@{{host}}.opval.com \
        --sudo

# Provisionner un nouveau serveur (nixos-anywhere)
anywhere host ip:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#{{host}} root@{{ip}}

# --- Section Maintenance & Ops ---

# Voir les logs de Vaultwarden sur un hôte
logs host='ix':
    ssh flebel@{{host}}.opval.com "sudo journalctl -u vaultwarden -f"

# Lancer manuellement un backup Restic sur l'hôte
backup host='ix':
    ssh flebel@{{host}}.opval.com "sudo systemctl start restic-backups-vaultwarden.service && sudo journalctl -u restic-backups-vaultwarden.service -f"

# Formater le code (par défaut le dossier courant '.')
fmt path='.':
    nix fmt {{path}}

# Vérifier la syntaxe et les types sans builder
check:
    nix flake check --show-trace

# Mettre à jour les entrées du flake
update:
    nix flake update
