{
  lib,
  flake-parts-lib,
  ...
}:

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      imports = import ./modules;

      options.defaults = {
        devShell = lib.mkOption {
          description = "Development shell that realizes the defaults.";
          readOnly = true;
          type = lib.types.package;
        };
        packages = lib.mkOption {
          description = "Packages to install into a development shell.";
          example = lib.literalExpression "[ pkgs.nil ]";
          default = [ ];
          type = with lib.types; listOf package;
        };
        shellHook = lib.mkOption {
          description = "Shell hook for a development shell.";
          example = /* bash */ ''
            git config diff.sops.textconv "sops decrypt"
          '';
          default = "";
          type = lib.types.lines;
        };
      };

      config.defaults.devShell = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
        inherit (config.defaults) packages shellHook;
      };
    }
  );
}
