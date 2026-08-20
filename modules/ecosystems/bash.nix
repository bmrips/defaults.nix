{
  config,
  lib,
  ...
}:

{
  options.ecosystems.bash.enable = lib.mkEnableOption "tools for Bash development";

  config = lib.mkIf config.ecosystems.bash.enable {
    git.attributes = [
      "*.bash diff=bash"
      "*.sh diff=bash"
    ];
    pre-commit.settings.hooks = {
      check-executables-have-shebangs.enable = true;
      check-shebang-scripts-are-executable.enable = true;
      shellcheck.enable = true;
    };
    treefmt.programs.shfmt.enable = true;
  };
}
