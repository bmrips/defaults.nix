{
  config,
  dlib,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.sops.enable = lib.mkEnableOption "tools for SOPS development" // {
    default = dlib.hasFile ".sops.yaml";
  };

  config = lib.mkIf config.ecosystems.sops.enable {
    make-shells.default.packages = [
      pkgs.sops
      (pkgs.defaults.git.wrap { settings.diff.sops.textconv = "sops decrypt"; })
    ];
  };
}
