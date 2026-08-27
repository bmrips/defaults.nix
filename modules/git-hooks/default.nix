{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkMerge [

  {
    ecosystems.toml.enable = true; # for typos.toml

    pre-commit.settings = {
      package = pkgs.prek;
      hooks = {
        check-added-large-files.enable = true;
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        check-vcs-permalinks.enable = true;
        convco.enable = true;
        detect-private-keys.enable = true;
        mixed-line-endings.enable = true;
        trim-trailing-whitespace.enable = true;
        typos.enable = true;
      };
    };
  }

  (lib.mkIf config.pre-commit.settings.enable {
    git.ignore."." = [ "/.pre-commit-config.yaml" ];
    make-shells.default.inputsFrom = [ config.pre-commit.devShell ];
  })

]
