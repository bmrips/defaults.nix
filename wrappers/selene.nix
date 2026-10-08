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
  yaml = self.defaults.formats.yaml_1_2 { };

  settingsFile = toml.generate "selene.toml" config.settings;
  settingsDir = self.linkFarm "selene-settings" [
    {
      name = "selene.toml";
      path = settingsFile;
    }
    {
      name = "std.yaml";
      path = yaml.generate "std.yaml" config.standardLibrary;
    }
  ];
in
{
  imports = [ wlib.modules.default ];

  options = {
    settings = lib.mkOption {
      description = "Settings for `selene`, written to `selene.toml`.";
      default = { };
      inherit (toml) type;
    };
    standardLibrary = lib.mkOption {
      description = "The standard library used in this project.";
      default = { };
      inherit (yaml) type;
    };
  };

  config = {
    flags."--config" = lib.mkIf (config.settings != { }) (
      if config.standardLibrary != { } then "${settingsDir}/selene.toml" else settingsFile
    );
    package = super.selene;
    settings.std = lib.mkIf (config.standardLibrary != { }) "std";
  };
}
