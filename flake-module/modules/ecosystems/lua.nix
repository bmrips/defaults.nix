{
  config,
  dlib,
  lib,
  ...
}:

{
  options.ecosystems.lua.enable = lib.mkEnableOption "tools for Lua development" // {
    default = dlib.hasFileWithExtension "lua";
  };

  config = lib.mkIf config.ecosystems.lua.enable {
    pre-commit.settings.hooks.selene.enable = true;
    treefmt.programs.stylua.enable = true;
  };
}
