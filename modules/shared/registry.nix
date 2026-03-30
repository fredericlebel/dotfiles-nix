{ lib, ... }:
{
  options.my.registry = {
    dockApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Liste des applications à épingler au Dock (collectée via les modules)";
    };
  };
}
