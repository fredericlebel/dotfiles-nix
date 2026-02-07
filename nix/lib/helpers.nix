{ inputs, user, ... }:
let
  defaultMeta = {
    adminEmail = "flebel@opval.com";
    baseDomain = "opval.com";
  };
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

      homeManagerModule =
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

        homeManagerModule
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = { inherit inputs user myMeta; };
            users.${user} = {
              imports = [
                ../../hosts/${hostName}/home.nix
              ];
            };
          };
        }
      ];
    };
}
