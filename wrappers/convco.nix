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
      header = "# Changelog";
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
          type = "refactor";
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
      preMajor = false;
      commitUrlFormat = "{{@root.host}}/{{@root.owner}}/{{@root.repository}}/commit/{{hash}}";
      compareUrlFormat = "{{@root.host}}/{{@root.owner}}/{{@root.repository}}/compare/{{previousTag}}...{{currentTag}}";
      issueUrlFormat = "{{@root.host}}/{{@root.owner}}/{{@root.repository}}/issues/{{issue}}";
      userUrlFormat = "{{host}}/{{user}}";
      releaseCommitMessageFormat = "chore(release): {{currentTag}}";
      issuePrefixes = [ "#" ];
      host = null;
      owner = null;
      repository = null;
      template = null;
      commitTemplate = null;
      scopeRegex = "^[[:alnum:]]+(?:[-_/][[:alnum:]]+)*$";
      lineLength = 50;
      wrapDisabled = false;
      linkCompare = true;
      linkReferences = true;
      merges = false;
      firstParent = false;
      stripRegex = "(fixup|squash)! ";
      description.length = {
        min = 10;
        max = null;
      };
    };
  };
}
