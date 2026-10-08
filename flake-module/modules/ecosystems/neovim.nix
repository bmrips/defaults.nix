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
    pre-commit.settings.hooks.selene.package = dlib.mkDefault (
      pkgs.defaults.selene.wrap {
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
        settings.lints.mixed_table = "allow";
      }
    );
  };
}
