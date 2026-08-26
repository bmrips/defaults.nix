{ config, lib, ... }:

lib.mkIf config.treefmt.programs.latexindent.enable {
  git.ignore = [ "*.bak*" ];
}
