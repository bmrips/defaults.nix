{ config, lib, ... }:

{
  options.ecosystems.github.enable = lib.mkEnableOption "tools for GitHub development";

  config = lib.mkIf config.ecosystems.github.enable {
    ecosystems.yaml.enable = true; # for `.github/`
    pre-commit.settings.hooks.actionlint.enable = true;
  };
}
