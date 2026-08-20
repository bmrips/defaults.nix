{ lib, config, ... }:

let
  cfg = config.git;
in
{
  options.git = {
    attributes = lib.mkOption {
      description = "Git per-path attributes, written to `.gitattributes`.";
      example = "* text=auto eol=lf";
      default = [ ];
      type = with lib.types; listOf str;
      apply = lib.naturalSort;
    };
    ignore = lib.mkOption {
      description = "Git ignore patterns, written to `.gitignore`.";
      example = "/.pre-commit-config.yaml";
      default = [ ];
      type = with lib.types; listOf str;
      apply = lib.naturalSort;
    };
  };

  config = {
    files.file = {
      ".gitattributes".text = lib.concatLines cfg.attributes;
      ".gitignore".text = lib.concatLines cfg.ignore;
    };
    git = {
      attributes = [ "* text=auto eol=lf" ];
      ignore = [
        "result"
        "result-*"
      ];
    };
  };
}
