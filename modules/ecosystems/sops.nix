{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.sops.enable = lib.mkEnableOption "tools for SOPS development";

  config = lib.mkIf config.ecosystems.sops.enable {
    make-shells.default = {
      packages = [ pkgs.sops ];
      shellHook = /* bash */ ''
        git config diff.sops.textconv "sops decrypt"
      '';
    };
    ecosystems.yaml.enable = true; # for `.sops.yaml`
  };
}
