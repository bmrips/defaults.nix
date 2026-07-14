{ config, lib, ... }:

{
  options.ecosystems.lua.enable = lib.mkEnableOption "tools for Lua development";

  config = lib.mkIf config.ecosystems.lua.enable {
    ecosystems = {
      toml.enable = true; # for `selene.toml`
      yaml.enable = true; # for `<std>.yaml`
    };
    pre-commit.settings.hooks.selene.enable = true;
    treefmt.programs.stylua.enable = true;
  };
}
