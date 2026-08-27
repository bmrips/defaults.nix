{ config, lib, ... }:

lib.mkIf config.treefmt.programs.latexindent.enable {
  git.ignore.${config.ecosystems.tex.root} = [
    "/*.bak*"
    "/indent\.log"
  ];
}
