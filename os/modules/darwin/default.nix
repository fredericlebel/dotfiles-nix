{ lib, ... }:
let
  findModules = (import ../../nix/lib/findNixModules.nix { inherit lib; }).findNixModules;
in
{
  imports = findModules ./features;
}
