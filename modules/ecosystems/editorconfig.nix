{
  config,
  dlib,
  lib,
  ...
}:

{
  options.ecosystems.editorconfig.enable =
    lib.mkEnableOption "tools for EditorConfig development"
    // {
      default = dlib.hasFile ".editorconfig";
    };

  config = lib.mkIf config.ecosystems.editorconfig.enable {
    pre-commit.settings.hooks.editorconfig-checker.enable = true;
  };
}
