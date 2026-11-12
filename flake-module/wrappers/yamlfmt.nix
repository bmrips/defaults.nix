{
  config,
  dlib,
  final,
  lib,
  prev,
  wlib,
  ...
}:

let
  yaml = final.defaults.formats.yaml_1_2 { };
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
      "--no_global_conf" = dlib.mkDefault true;
    };
    package = prev.yamlfmt;
    settings.formatter = dlib.mkDefault {
      force_array_style = "block";
      force_quote_style = "double";
      pad_line_comments = 2;
      retain_line_breaks_single = true;
      type = "basic";
    };
  };
}
