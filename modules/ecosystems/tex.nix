{ config, lib, ... }:

{
  options.ecosystems.tex.enable = lib.mkEnableOption "tools for TeX development";

  config = lib.mkIf config.ecosystems.tex.enable {
    pre-commit.settings.hooks.chktex.enable = true;
    treefmt.programs.latexindent.enable = true;
  };
}
