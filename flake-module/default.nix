inputs:

{ lib, self, ... }:

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

  flake.overlays =
    let
      mkWrappers =
        final: prev:
        builtins.mapAttrs (
          _: w:
          w.wrap {
            # NOTE: Use `_module.args` since nix-wrapper-modules can not yet
            # distinguish final/prev pkgs instances. See:
            # https://github.com/nix-community/nix-wrapper-modules/issues/629
            _module.args = { inherit final prev; };
            pkgs = final;
          }
        ) self.wrappers;
    in
    {
      defaults =
        final: prev:
        let
          inherit (final.stdenv.hostPlatform) system;
          legacyPackages = inputs.self.legacyPackages.${system};
        in
        {
          defaults = legacyPackages // mkWrappers final prev;
        };
      defaults-overrides =
        final: prev:
        removeAttrs (mkWrappers final prev) [
          # Overlaying these would break dependent derivations.
          "git"
          "shellcheck"

          # Not exposed on the top level.
          # NOTE: overlaying the `texlive.pkgs` causes an infinite recursion
          # error. See https://github.com/NixOS/nixpkgs/issues/582266.
          "chktex"
          "latexindent"
        ]
        // {
          haskell = prev.haskell // {
            packages = lib.mapAttrs (
              _: hPkgs:
              hPkgs
              // lib.optionalAttrs (hPkgs ? fourmolu) {
                fourmolu = self.wrappers.fourmolu.wrap { package = hPkgs.fourmolu; };
              }
            ) prev.haskell.packages;
          };
        };
    };

  perSystem = { system, ... }: {
    _module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          self.overlays.defaults
          self.overlays.defaults-overrides
        ];
      };
      root = self.outPath;
    };

    imports = inputs.import-tree.leaves ./modules;

    # Do not wire the wrappers into the `packages` output automatically.
    wrappers.control_type = "build";
  };
}
