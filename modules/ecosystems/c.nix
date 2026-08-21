{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.c.enable = lib.mkEnableOption "tools for C development";

  config = lib.mkIf config.ecosystems.c.enable {
    git.attributes = [
      "*.c diff=cpp"
      "*.c++ diff=cpp"
      "*.cpp diff=cpp"
      "*.h diff=cpp"
    ];
    make-shells.default.packages = with pkgs; [
      man-pages
      man-pages-posix
    ];
  };
}
