{ config, lib, ... }:

{
  options.ecosystems.tex.enable = lib.mkEnableOption "tools for TeX development";

  config = lib.mkIf config.ecosystems.tex.enable {
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
  };
}
