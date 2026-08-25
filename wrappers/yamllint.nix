{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = pkgs.formats.yaml { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `yamllint`, written to `.yamllint.yaml`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags."--config-file" = lib.mkIf (config.settings != { }) (
      yaml.generate "yamllint.yaml" config.settings
    );
    package = pkgs.yamllint;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      extends = "default";
      rules = {
        document-start = "disable";
        empty-values = "enable";
        float-values.require-numeral-before-decimal = true;
        line-length = "disable";
        octal-values.forbid-implicit-octal = true;
      };
    };
  };
}
