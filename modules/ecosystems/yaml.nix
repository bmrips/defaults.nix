{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.yaml.enable = lib.mkEnableOption "tools for YAML development";

  config = lib.mkIf config.ecosystems.yaml.enable {
    make-shells.default.packages = [ pkgs.yq-go ];
    pre-commit.settings.hooks = {
      check-yaml.enable = true;
      yamllint.enable = true;
    };
    treefmt.programs.yamlfmt.enable = true;
  };
}
