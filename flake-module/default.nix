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

  flake.overlays =
    let
      mkWrappers =
        self: super:
        builtins.mapAttrs (
          _: w:
          w.wrap {
            # NOTE: Use `_module.args` since nix-wrapper-modules can not yet
            # distinguish self/super pkgs instances. See:
            # https://github.com/nix-community/nix-wrapper-modules/issues/629
            _module.args = { inherit self super; };
            pkgs = self;
          }
        ) self.wrappers;
    in
    {
      defaults =
        self: super:
        let
          inherit (self.stdenv.hostPlatform) system;
          legacyPackages = inputs.self.legacyPackages.${system};
        in
        {
          defaults = legacyPackages // mkWrappers self super;
        };
      defaults-overrides =
        self: super:
        removeAttrs (mkWrappers self super) [
          # Overlaying these would break dependent derivations.
          "git"
          "shellcheck"

          # Not exposed on the top level.
          # NOTE: overlaying the `texlive.pkgs` causes an infinite recursion
          # error. See https://github.com/NixOS/nixpkgs/issues/582266.
          "chktex"
          "latexindent"
        ];
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
