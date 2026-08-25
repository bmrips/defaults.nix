{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = pkgs.formats.yaml_1_2 { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `markdownlint`, written to `.markdownlint.yaml`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags."--config" = lib.mkIf (config.settings != { }) (
      yaml.generate "markdownlint.yaml" config.settings
    );
    package = pkgs.markdownlint-cli;
    settings.line_length = lib.mkDefault false;
  };
}
