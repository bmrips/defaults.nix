{ config, lib, ... }:

{
  options.ecosystems.markdown.enable = lib.mkEnableOption "tools for Markdown development";

  config = lib.mkIf config.ecosystems.markdown.enable {
    ecosystems.yaml.enable = true; # for `.markdownlint.yaml`
    git.attributes = [
      "*.md diff=markdown"
      "*.markdown diff=markdown"
    ];
    pre-commit.settings.hooks.markdownlint.enable = true;
    treefmt.programs.mdformat.enable = true;
  };
}
