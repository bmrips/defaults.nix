{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = pkgs.formats.yaml_1_2 { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `convco`, written to `.convco`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags."--config" = lib.mkIf (config.settings != { }) (yaml.generate "convco.yaml" config.settings);
    package = pkgs.convco;

    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      types = [
        {
          type = "feat";
          increment = "Minor";
          section = "Features";
          hidden = false;
        }
        {
          type = "fix";
          increment = "Patch";
          section = "Fixes";
          hidden = false;
        }
        {
          type = "build";
          increment = "None";
          section = "Other";
          hidden = true;
        }
        {
          type = "chore";
          increment = "None";
          section = "Other";
          hidden = true;
        }
        {
          type = "ci";
          increment = "None";
          section = "Other";
          hidden = true;
        }
        {
          type = "docs";
          increment = "None";
          section = "Documentation";
          hidden = true;
        }
        {
          type = "style";
          increment = "None";
          section = "Other";
          hidden = true;
        }
        {
          type = "ref";
          increment = "None";
          section = "Other";
          hidden = true;
        }
        {
          type = "perf";
          increment = "None";
          section = "Performance";
          hidden = true;
        }
        {
          type = "test";
          increment = "None";
          section = "Other";
          hidden = true;
        }
      ];
      stripRegex = "(fixup|squash)! ";
    };
  };
}
