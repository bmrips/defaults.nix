{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  cfg = config.ecosystems.haskell;

  # Circumvent a bug in the interaction of Cabal and `shellFor`.
  # https://gist.github.com/ScottFreeCode/ef9f254e2dd91544bba4a068852fc81f
  # https://github.com/NixOS/nixpkgs/issues/130556#issuecomment-2762237786
  cabal-in-nix = pkgs.symlinkJoin {
    name = "cabal-in-nix";
    paths = [ pkgs.cabal-install ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cabal --add-flag --flags=+nix
    '';
  };

  hPkgs = pkgs.haskellPackages;

  ghcDevShell = hPkgs.shellFor {
    packages = _: [ cfg.cabal.package ];
    withHoogle = true;
    nativeBuildInputs = [ cabal-in-nix ];
  };
in
{
  options.ecosystems.haskell = {
    enable = lib.mkEnableOption "tools for Haskell development";
    cabal = lib.mkOption {
      description = ''
        Build a contained cabal package. It is made accessible through the
        `package` option. All options except for `package` are passed to
        `haskellPackages.developPackage`.
      '';
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          package = lib.mkOption {
            description = ''
              The derivation resulting from `haskellPackage.developPackage`.
            '';
            type = lib.types.package;
            readOnly = true;
          };
          name = lib.mkOption {
            description = ''
              The name of the package. It is used to determine the file name of
              the package description.
            '';
            example = "my-library";
            type = lib.types.str;
          };
          root = lib.mkOption {
            description = ''
              The root of the package containing the package description.
            '';
            example = lib.literalExpression "./.";
            default = self;
            type = lib.types.pathInStore;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      {
        ecosystems.yaml.enable = true; # for `fourmolu.yaml`
        pre-commit.settings.hooks.hlint.enable = true;
        treefmt.programs.fourmolu.enable = true;
      }

      (lib.mkIf cfg.cabal.enable {
        direnv.watchedFiles = [ "*.cabal" ];
        ecosystems.haskell.cabal.package = hPkgs.developPackage (lib.removeAttrs cfg.cabal [ "package" ]);
        git.ignore = [
          "/cabal.project.local"
          "/cabal.project.local~"
          "/dist-*/"
          "/dist/"
        ];
        make-shells.default.inputsFrom = [ ghcDevShell ];
        treefmt.programs.cabal-gild.enable = true;
      })

    ]
  );
}
