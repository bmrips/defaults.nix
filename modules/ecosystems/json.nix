{
  config,
  dlib,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ecosystems.json;
in
{
  options.ecosystems.json.enable = lib.mkEnableOption "tools for JSON development" // {
    default = dlib.hasFileWithExtension "json";
  };

  config = lib.mkIf cfg.enable {
    make-shells.default.packages = [ pkgs.jq ];
    pre-commit.settings.hooks.check-json.enable = true;
    treefmt.programs.oxfmt.enable = true;
  };
}
