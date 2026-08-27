{
  config,
  lib,
  options,
  pkgs,
  root,
  ...
}:

let
  cfg = config.ecosystems.haskell;
  pkgCfg = cfg.cabalPackage;

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
    packages = _: [ pkgCfg.drv ];
    withHoogle = true;
    nativeBuildInputs = [ cabal-in-nix ];
  };
in
{
  options.ecosystems.haskell = {
    enable = lib.mkEnableOption "tools for Haskell development";
    cabalPackage = {
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
          The directory containing the package description; relative to the flake.
        '';
        default = ".";
        type = lib.types.str;
        apply = path: lib.removePrefix "./" (lib.path.subpath.normalise path);
      };
      args = lib.mkOption {
        description = "The arguments passed to `haskellPackages.developPackage`.";
        default = { };
        type = with lib.types; attrsOf anything;
      };
      drv = lib.mkOption {
        description = "A derivation containing the cabal package.";
        type = lib.types.package;
        readOnly = true;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      {
        pre-commit.settings.hooks.hlint.enable = true;
        treefmt.programs.fourmolu.enable = true;
      }

      (lib.mkIf options.ecosystems.haskell.cabalPackage.name.isDefined {
        direnv.watchedFiles = [ "${pkgCfg.root}/${pkgCfg.name}.cabal" ];
        ecosystems.haskell.cabalPackage = {
          args = {
            inherit (pkgCfg) name;
            root = root + "/" + pkgCfg.root;
          };
          drv = hPkgs.developPackage pkgCfg.args;
        };
        git.ignore = map (p: "/" + pkgCfg.root + p) [
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
