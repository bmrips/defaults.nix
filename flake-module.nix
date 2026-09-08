inputs:

{ self, ... }:

{
  imports = [
    "${inputs.files}/flake-module.nix"
    "${inputs.make-shell}/flake-module.nix"
    "${inputs.pre-commit}/flake-module.nix"
    "${inputs.treefmt}/flake-module.nix"
  ];

  perSystem = { system, ... }: {
    _module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.default ];
      };
      root = self.outPath;
    };
    imports = inputs.import-tree.leafs ./modules;
  };
}
