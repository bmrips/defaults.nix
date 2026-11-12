{
  config,
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
    description = "Settings for `statix`, written to `statix.toml`.";
    default = { };
    inherit (toml) type;
  };

  config = {
    appendFlag = lib.mkIf (config.settings != { }) [
      "--config"
      (toml.generate "statix.toml" config.settings)
    ];
    package = prev.statix;
    settings.disabled = [ "repeated_keys" ];
  };
}
