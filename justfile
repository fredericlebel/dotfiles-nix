default:
    @just --list

bootstrap:
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

build host:
    nix build
    sudo ./result/sw/bin/darwin-rebuild switch --impure --flake .#{{host}} --show-trace --verbose

fmt:
    nix fmt

history:
    nix profile history --profile /nix/var/nix/profiles/system

update:
    nix flake update


nixos-anywhere:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#ix flebel@ix.opval.com

nixos-rebuild:
    nix run nixpkgs#nixos-rebuild -- switch \
        --flake .#ix \
        --target-host flebel@ix.opval.com \
        --build-host flebel@ix.opval.com \
        --sudo
