{ lib, self, ... }:

let
  importModule =
    path: _type:
    let
      name = lib.removeSuffix ".nix" path;
      path' = ./. + "/${path}";
    in
    {
      ${name} = { pkgs, ... }: {
        _module.args.defaultsPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
        imports = [ path' ];
      };
    };
in
{
  flake.wrappers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (path: _: path != "default.nix"))
    (lib.concatMapAttrs importModule)
  ];
}
