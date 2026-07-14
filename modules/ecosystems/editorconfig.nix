{ config, lib, ... }:

{
  options.ecosystems.editorconfig.enable = lib.mkEnableOption "tools for EditorConfig development";

  config = lib.mkIf config.ecosystems.editorconfig.enable {
    pre-commit.settings.hooks.editorconfig-checker.enable = true;
  };
}
