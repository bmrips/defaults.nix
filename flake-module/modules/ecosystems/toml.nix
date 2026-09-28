{
  config,
  dlib,
  lib,
  ...
}:

{
  options.ecosystems.toml.enable = lib.mkEnableOption "tools for TOML development" // {
    default = dlib.hasFileWithExtension "toml";
  };

  config = lib.mkIf config.ecosystems.toml.enable {
    pre-commit.settings.hooks.check-toml.enable = true;
    treefmt.programs.taplo.enable = true;
  };
}
