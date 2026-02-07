{
  description = "Environnement de développement isolé pour nix-config";

  inputs = {
    # On reste sur unstable pour avoir les dernières versions des outils
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # On importe colmena séparément pour garantir la compatibilité
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, colmena }:
    let
      # On supporte tes deux architectures
      systems = [ "aarch64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "nix-config-dev-shell";

            # On utilise nativeBuildInputs pour les outils CLI
            nativeBuildInputs = [
              pkgs.just
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.git
              pkgs.statix
              pkgs.deadnix
              pkgs.nh
              pkgs.nix-output-monitor
              # On récupère colmena via son propre input pour être safe
              colmena.packages.${system}.colmena
            ];

            shellHook = ''
              echo "🛡️  Environnement de dev ISOLÉ chargé (nix/dev)"
              echo "🚀 Outils prêts : colmena, just, sops, nh, statix"
            '';
          };
        }
      );
    };
}
