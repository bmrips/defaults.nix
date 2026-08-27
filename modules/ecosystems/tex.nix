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
      description = "The directory of the documents relative to the flake.";
      default = ".";
      type = lib.types.str;
      apply = path: lib.removePrefix "./" (lib.path.subpath.normalise path);
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
    ecosystems.tex.documents = pkgs.stdenvNoCC.mkDerivation {
      name = "documents";
      src = root + "/" + cfg.root;
      nativeBuildInputs = [ cfg.texliveEnv ];
    };

    files.file."${cfg.root}/latexmkrc".text = /* perl */ ''
      $bibtex_use = 1.5; # cleanup .bbl files if all bib files exist
      $out2_dir = ".";
      $out_dir = "build/";
      $pdf_mode = 1; # use PDFLaTeX
      $warnings_as_errors = 1;
    '';

    git = {
      attributes = [
        "*.bib diff=bibtex"
        "*.cls diff=tex"
        "*.sty diff=tex"
        "*.tex diff=tex"
      ];
      ignore.${cfg.root} = [
        "/*.synctex"
        "/*.synctex.gz"
        "/*.pdf"
        "/build/"
      ];
    };

    make-shells.default.inputsFrom = [ cfg.documents ];

    pre-commit.settings.hooks.chktex.enable = true;

    treefmt.programs.latexindent.enable = true;
  };
}
