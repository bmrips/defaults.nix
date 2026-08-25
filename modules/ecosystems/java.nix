{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ecosystems.java;
in
{
  options.ecosystems.java = {
    enable = lib.mkEnableOption "tools for Java development";
    withJavaFX = lib.mkEnableOption "JavaFX";
  };

  config = lib.mkIf cfg.enable {
    make-shells.default.packages = [ (pkgs.openjdk.override { enableJavaFX = cfg.withJavaFX; }) ];
    treefmt.programs.google-java-format.enable = true;
  };
}
