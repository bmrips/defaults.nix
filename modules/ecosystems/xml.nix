{
  config,
  lib,
  ...
}:

{
  options.ecosystems.xml.enable = lib.mkEnableOption "tools for YAML development";

  config = lib.mkIf config.ecosystems.xml.enable {
    pre-commit.settings.hooks.check-xml.enable = true;
    treefmt.programs.xmllint.enable = true;
  };
}
