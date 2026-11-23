{
  config,
  dlib,
  lib,
  pkgs,
  ...
}:

{
  options.ecosystems.neovim.enable = lib.mkEnableOption "tools for Lua scripting in Neovim" // {
    default = dlib.hasFile ".nvim.lua";
  };

  config = lib.mkIf config.ecosystems.neovim.enable {
    pre-commit.settings.hooks.selene.package =
      let
        prio = (dlib.defaultOverridePriority + lib.modules.defaultOverridePriority) / 2;
      in
      dlib.mkOverride prio (
        pkgs.wrappers.selene.wrap {
          settings.lints.mixed_table = "allow";
          standardLibrary = {
            base = "lua51";
            lua_versions = [ "luajit" ];
            globals = {
              "assert".args = [
                { type = "any"; }
                {
                  type = "string";
                  required = false;
                }
              ];
              Snacks.any = true;
              vim.any = true;
            };
          };
        }
      );
  };
}
