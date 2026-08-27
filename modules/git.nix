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
      description = ''
        Per-directory Git ignore patterns, written to `<key>/.gitignore`.
        Refer to the root of the flake as `"/"`.
      '';
      example = "/.pre-commit-config.yaml";
      default = [ ];
      type = with lib.types; attrsOf (listOf str);
      apply = lib.mapAttrs (_: lib.naturalSort);
    };
    upstream = {
      host = lib.mkOption {
        description = "The server hosting the upstream repository";
        default = "https://github.com";
        type = lib.types.str;
      };
      owner = lib.mkOption {
        description = "The owner of the upstream repository";
        default = "bmrips";
        type = lib.types.str;
      };
      repository = lib.mkOption {
        description = "The name of the upstream repository";
        type = lib.types.str;
      };
    };
  };

  config = {

    files.file = {
      ".gitattributes".text = lib.concatLines cfg.attributes;
    }
    // lib.mapAttrs' (dir: patterns: {
      name = "${dir}/.gitignore";
      value.text = lib.concatLines patterns;
    }) cfg.ignore;

    git = {
      attributes = [ "* text=auto eol=lf" ];
      ignore."." = [
        "result"
        "result-*"
      ];
    };

  };
}
