{
  description = "My default configuration for tools";

  inputs = {
    files.url = "github:mightyiam/files";
    files.flake = false;
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    make-shell.url = "github:nicknovitski/make-shell";
    make-shell.flake = false;
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    pre-commit.flake = false;
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.flake = false;
    wrappers.url = "github:nix-community/nix-wrapper-modules";
    wrappers.flake = false;
  };

  outputs =
    inputs:
    let
      flakeModule = import ./flake-module inputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flakeModule
        ./wrappers
      ];

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      flake.flakeModule = flakeModule;

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
            ) inputs.self.wrappers;
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
          overrides =
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

      perSystem = { lib, pkgs, ... }: {
        imports = [ ./pkgs-lib.nix ];
        direnv.watchedDirectories = [
          "flake-module/"
          "wrappers/"
        ];

        # Wire the wrappers into the `packages` output manually since the
        # auto-wiring results in nested wrappers.
        wrappers.control_type = "build";
        packages = lib.intersectAttrs inputs.self.wrappers pkgs.defaults;
      };
    };
}
