{ pkgs, ... }:

let
  configFile = pkgs.writers.writeYAML "yamllint.yaml" {
    extends = "default";
    rules = {
      document-start = "disable";
      empty-values = "enable";
      float-values.require-numeral-before-decimal = true;
      line-length = "disable";
      octal-values.forbid-implicit-octal = true;
    };
  };
in
{
  pre-commit.settings.hooks.yamllint.settings.configPath = "${configFile}";
}
