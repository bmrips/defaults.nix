{
  inputs,
  dlib,
  lib,
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
        _module.args = {
          inherit dlib;
          # NOTE: Use `_module.args` since nix-wrapper-modules can not yet
          # distinguish self/super pkgs instances. See:
          # https://github.com/nix-community/nix-wrapper-modules/issues/629
          self = lib.mkDefault pkgs;
          super = lib.mkDefault pkgs;
        };
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
