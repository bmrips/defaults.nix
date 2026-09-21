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
    description = "Settings for `statix`, written to `statix.toml`.";
    default = { };
    inherit (toml) type;
  };

  config = {
    appendFlag = lib.mkIf (config.settings != { }) [
      "--config"
      (toml.generate "statix.toml" config.settings)
    ];
    package = pkgs.statix;
    settings.disabled = lib.mkDefault [ "repeated_keys" ];
  };
}
