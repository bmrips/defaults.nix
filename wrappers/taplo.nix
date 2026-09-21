{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  toml = pkgs.formats.toml { };
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
    package = pkgs.taplo;
    settings.formatting.array_auto_collapse = lib.mkDefault false;
  };
}
