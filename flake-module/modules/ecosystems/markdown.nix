{
  config,
  dlib,
  lib,
  ...
}:

{
  options.ecosystems.markdown.enable = lib.mkEnableOption "tools for Markdown development" // {
    default = dlib.hasFileWithExtension [
      "markdown"
      "md"
    ];
  };

  config = lib.mkIf config.ecosystems.markdown.enable {
    git.attributes = [
      "*.md diff=markdown"
      "*.markdown diff=markdown"
    ];
    pre-commit.settings.hooks.markdownlint.enable = dlib.mkDefault true;
    treefmt.programs.mdformat.enable = dlib.mkDefault true;
  };
}
