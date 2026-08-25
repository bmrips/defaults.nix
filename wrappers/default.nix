{ lib, ... }:

let
  importModule =
    path: _type:
    let
      name = lib.removeSuffix ".nix" path;
      path' = ./. + "/${path}";
    in
    {
      ${name}.imports = [ path' ];
    };
in
{
  flake.wrappers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (path: _: path != "default.nix"))
    (lib.concatMapAttrs importModule)
  ];
}
