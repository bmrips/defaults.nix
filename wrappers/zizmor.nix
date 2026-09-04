{
  config,
  defaultsPkgs,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = defaultsPkgs.formats.yaml_1_2 { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `zizmor`, written to `zizmor.yaml`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags = {
      "--config" = lib.mkIf (config.settings != { }) (yaml.generate "zizmor.yaml" config.settings);
      "--persona" = lib.mkDefault "pedantic";
    };
    package = pkgs.zizmor;
  };
}
