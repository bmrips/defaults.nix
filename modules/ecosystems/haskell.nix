{ config, lib, ... }:

{
  options.ecosystems.haskell.enable = lib.mkEnableOption "tools for Haskell development";

  config = lib.mkIf config.ecosystems.haskell.enable {
    ecosystems.yaml.enable = true; # for `fourmolu.yaml`
    pre-commit.settings.hooks.hlint.enable = true;
    treefmt.programs = {
      cabal-gild.enable = true;
      fourmolu.enable = true;
    };
  };
}
