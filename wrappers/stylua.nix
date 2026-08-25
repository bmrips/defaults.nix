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
    description = "Settings for `stylua`, written to `stylua.toml`.";
    default = { };
    inherit (toml) type;
  };

  config = {
    flags."--config-path" = lib.mkIf (config.settings != { }) (
      toml.generate "stylua.toml" config.settings
    );
    package = pkgs.stylua;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      call_parentheses = "None";
      column_width = 100;
      indent_type = "Spaces";
      indent_width = 2;
      quote_style = "AutoPreferSingle";
    };
  };
}
