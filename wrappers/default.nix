{
  inputs,
  lib,
  self,
  ...
}:

let
  importModule =
    path: _type:
    let
      name = lib.removeSuffix ".nix" path;
      path' = ./. + "/${path}";
    in
    {
      ${name} = { pkgs, ... }: {
        _module.args.defaultsPkgs =
          let
            inherit (pkgs.stdenv.hostPlatform) system;
          in
          self.packages.${system} // self.legacyPackages.${system};
        imports = [ path' ];
      };
    };
in
{
  imports = [ "${inputs.wrappers}/parts.nix" ];

  flake.wrappers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (path: _: path != "default.nix"))
    (lib.concatMapAttrs importModule)
  ];
}
