inputs:

{ lib, self, ... }:

let
  collectModules =
    path:
    lib.collect builtins.isPath (
      inputs.haumea.lib.load {
        src = path;
        loader = inputs.haumea.lib.loaders.path;
      }
    );
in
{
  imports = [
    "${inputs.files}/flake-module.nix"
    "${inputs.make-shell}/flake-module.nix"
    "${inputs.pre-commit}/flake-module.nix"
    "${inputs.treefmt}/flake-module.nix"
  ];

  perSystem = {
    _module.args.root = self.outPath;
    imports = collectModules ./modules;
  };
}
