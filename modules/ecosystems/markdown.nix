{ config, lib, ... }:

{
  options.ecosystems.markdown.enable = lib.mkEnableOption "tools for Markdown development";

  config = lib.mkIf config.ecosystems.markdown.enable {
    ecosystems.yaml.enable = true; # for `.markdownlint.yaml`
    pre-commit.settings.hooks.markdownlint.enable = true;
    treefmt.programs.mdformat.enable = true;
  };
}
