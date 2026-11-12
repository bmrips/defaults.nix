{
  config,
  lib,
  self,
  super,
  wlib,
  ...
}:

let
  toml = self.formats.toml { };
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
    package = super.statix;
    settings.disabled = [ "repeated_keys" ];
  };
}
