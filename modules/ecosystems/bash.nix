{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.bash.enable = lib.mkEnableOption "tools for Bash development";

  config = lib.mkIf config.ecosystems.bash.enable {
    defaults.packages = [ pkgs.checkbashisms ];
    pre-commit.settings.hooks = {
      check-executables-have-shebangs.enable = true;
      check-shebang-scripts-are-executable.enable = true;
      shellcheck.enable = true;
    };
    treefmt.programs.shfmt.enable = true;
  };
}
