{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.sops.enable = lib.mkEnableOption "tools for SOPS development";

  config = lib.mkIf config.ecosystems.sops.enable {
    ecosystems.yaml.enable = true; # for `.sops.yaml`
    make-shells.default.packages = [
      pkgs.sops
      (pkgs.defaults.git.wrap { settings.diff.sops.textconv = "sops decrypt"; })
    ];
  };
}
