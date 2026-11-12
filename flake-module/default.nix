inputs:

{ self, ... }:

{
  imports = [
    "${inputs.files}/flake-module.nix"
    "${inputs.make-shell}/flake-module.nix"
    "${inputs.pre-commit}/flake-module.nix"
    "${inputs.treefmt}/flake-module.nix"
    "${inputs.wrappers}/parts.nix"
    ./lib.nix
    ./wrappers
  ];

  flake.overlays.default =
    final: prev:
    let
      inherit (final.stdenv.hostPlatform) system;
      legacyPackages = inputs.self.legacyPackages.${system};
      wrappers = builtins.mapAttrs (
        _: w:
        w.wrap {
          # NOTE: Use `_module.args` since nix-wrapper-modules can not yet
          # distinguish self/super pkgs instances. See:
          # https://github.com/nix-community/nix-wrapper-modules/issues/629
          _module.args = { inherit final prev; };
          pkgs = final;
        }
      ) self.wrappers;
    in
    {
      defaults = legacyPackages // wrappers;
    };

  perSystem = { system, ... }: {
    _module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
      root = self.outPath;
    };

    imports = inputs.import-tree.leaves ./modules;

    # Do not wire the wrappers into the `packages` output automatically.
    wrappers.control_type = "build";
  };
}
