{
  config,
  lib,
  pkgs,
  root,
  ...
}:

let
  cfg = config.ecosystems.tex;
in
{
  options.ecosystems.tex = {
    enable = lib.mkEnableOption "tools for TeX development";
    root = lib.mkOption {
      description = "The root directory of the document.";
      example = lib.literalExpression "./.";
      default = root;
      defaultText = "self.outPath";
      type = lib.types.path;
    };
    texliveEnv = lib.mkOption {
      description = "The TeX Live environment used for the build.";
      default = pkgs.texliveFull;
      defaultText = "pkgs.texliveFull";
      type = lib.types.package;
      apply =
        env:
        if lib.any (drv: drv.pname == "latexmk") env.includedTeXPackages then
          env
        else
          env.withPackages (ps: [ ps.latexmk ]);
    };
    documents = lib.mkOption {
      description = ''
        A derivation containing all documents that are built by the Makefile.
      '';
      type = lib.types.package;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    git = {
      attributes = [
        "*.bib diff=bibtex"
        "*.cls diff=tex"
        "*.sty diff=tex"
        "*.tex diff=tex"
      ];
      ignore = import ./_gitignore.nix;
    };
    pre-commit.settings.hooks.chktex.enable = true;
    treefmt.programs.latexindent.enable = true;

    ecosystems.tex.documents = pkgs.stdenvNoCC.mkDerivation {
      name = "documents";
      src = cfg.root;
      nativeBuildInputs = [ cfg.texliveEnv ];
    };

    make-shells.default.inputsFrom = [ cfg.documents ];
  };
}
