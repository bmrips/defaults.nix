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
    description = "Settings for `yamlfmt`, written to `.yamlfmt.yaml`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags = {
      "--conf" = lib.mkIf (config.settings != { }) (yaml.generate "yamlfmt.yaml" config.settings);
      "--no_global_conf" = lib.mkDefault true;
    };
    package = pkgs.yamlfmt;
    settings.formatter = lib.mapAttrsRecursive (_: lib.mkDefault) {
      force_array_style = "block";
      force_quote_style = "double";
      pad_line_comments = 2;
      retain_line_breaks_single = true;
      type = "basic";
    };
  };
}
