{ dlib, lib, ... }:

let
  importModule =
    path: _type:
    let
      name = lib.removeSuffix ".nix" path;
      path' = ./. + "/${path}";
    in
    {
      ${name} = { pkgs, ... }: {
        _module.args = {
          inherit dlib;
          # NOTE: Use `_module.args` since nix-wrapper-modules can not yet
          # distinguish final/prev pkgs instances. See:
          # https://github.com/nix-community/nix-wrapper-modules/issues/629
          final = lib.mkDefault pkgs;
          prev = lib.mkDefault pkgs;
        };
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
