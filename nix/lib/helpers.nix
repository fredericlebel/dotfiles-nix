{ inputs, user, ... }:
let
  defaultMeta = import ./default-meta.nix;
in
{
  inherit defaultMeta;

  mkSystem =
    {
      hostName,
      spec,
    }:
    let
      lib = inputs.nixpkgs.lib;

      # On fusionne les metas par défaut avec celles de la spec
      myMeta = (defaultMeta // (spec.meta or { })) // {
        inherit (spec) system isDarwin;
        tags = (spec.deployment.tags or [ ]) ++ (spec.meta.tags or [ ]);
      };

      isDarwin = spec.isDarwin or false;
      system = spec.system;

      # Découverte automatique du fichier de secret (ex: secrets/ix.yaml)
      # On utilise une chaine pour le test puis on convertit en path si existant
      sopsFile = ../../secrets/${hostName}.yaml;
      hasSops = builtins.pathExists sopsFile;

      # Pattern Factory : On choisit le constructeur selon l'OS
      builder = if isDarwin then inputs.darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;

      osModules =
        if isDarwin then
          [
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.sops-nix.darwinModules.sops
          ]
        else
          [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];

      hmModule =
        if isDarwin then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    builder {
      # On injecte la spec complete dans specialArgs pour que tous les modules y aient accès
      specialArgs = {
        inherit inputs user myMeta;
        hostSpec = spec;
      };

      modules = osModules ++ [
        { nixpkgs.hostPlatform = system; }
        ../../nix/lib/meta-options.nix
        ../../hosts/${hostName}/configuration.nix
        hmModule
        {
          # On injecte myMeta et on configure Home Manager et SOPS
          config = {
            myMeta = myMeta;

            # Automatisation SOPS : Si le fichier secrets/<host>.yaml existe, on l utilise par défaut
            sops.defaultSopsFile = lib.mkIf hasSops sopsFile;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {
                inherit inputs user myMeta;
                hostSpec = spec;
              };
              users.${user} = {
                imports = [ ../../hosts/${hostName}/home.nix ];
              };
            };
          };
        }
      ];
    };
}
