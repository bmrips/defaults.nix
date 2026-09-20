{ config, lib, ... }:

{
  options.ecosystems.nix.enable = lib.mkEnableOption "tools for Nix development" // {
    default = true;
  };

  config = lib.mkIf config.ecosystems.nix.enable {
    pre-commit.settings.hooks = {
      deadnix.enable = true;
      statix.enable = true;
    };
    treefmt.programs = {
      nixf-diagnose.enable = true;
      nixfmt.enable = true;
    };
  };
}
