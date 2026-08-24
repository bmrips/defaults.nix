inputs:

{ self, ... }:

{
  imports = [
    "${inputs.files}/flake-module.nix"
    "${inputs.make-shell}/flake-module.nix"
    "${inputs.pre-commit}/flake-module.nix"
    "${inputs.treefmt}/flake-module.nix"
  ];

  perSystem = {
    _module.args.root = self.outPath;
    imports = inputs.import-tree.leafs ./modules;
  };
}
