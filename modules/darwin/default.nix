{ lib, ... }:
let
  findModules =
    dir:
    let
      entries = builtins.readDir dir;
      hasDefault = entries ? "default.nix" && entries."default.nix" == "regular";
    in
    if hasDefault && dir != ./features then
      [ (dir + "/default.nix") ]
    else
      lib.concatLists (
        lib.mapAttrsToList (
          name: type:
          let
            path = dir + "/${name}";
          in
          if type == "directory" then
            findModules path
          else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
            [ path ]
          else
            [ ]
        ) entries
      );
in
{
  imports = findModules ./features;
}
