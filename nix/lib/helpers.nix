{ inputs, user, ... }:
let
  defaultMeta = import ./default-meta.nix;
in
{
  inherit defaultMeta;

  mkSystem =
    {
      hostName,
      system,
      isDarwin ? false,
      hostMeta ? null,
    }:
    let
      localMeta = if hostMeta != null then hostMeta else import ../../hosts/${hostName}/host-meta.nix;
      myMeta = defaultMeta // localMeta;

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
            inputs.inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];

      hmModule =
        if isDarwin then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    builder {
      inherit system;
      specialArgs = { inherit inputs user myMeta; };

      modules = osModules ++ [
        ../../hosts/${hostName}/configuration.nix
        hmModule
        {
          home-manager = {
            useGlobalPkgs = true; # Source unique de vérité pour les paquets
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = { inherit inputs user myMeta; };
            users.${user} = {
              imports = [ ../../hosts/${hostName}/home.nix ];
            };
          };
        }
      ];
    };
}
