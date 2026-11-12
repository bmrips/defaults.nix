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
  toml = final.formats.toml { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `taplo`, written to `taplo.toml`.";
    default = { };
    inherit (toml) type;
  };

  config = {
    appendFlag = lib.mkIf (config.settings != { }) [
      "--config"
      (toml.generate "taplo.toml" config.settings)
    ];
    package = prev.taplo;
    settings.formatting.array_auto_collapse = dlib.mkDefault false;
  };
}
