{
  config,
  defaultsPkgs,
  lib,
  pkgs,
  ...
}:

let
  yaml = pkgs.formats.yaml_1_2 { };
  name = "nix-flake-check";
in
{
  options.ecosystems.github = {
    enable = lib.mkEnableOption "tools for GitHub development";

    workflows.${name} =
      let
        stepsOption =
          order:
          lib.mkOption {
            description = "Steps to run ${order} `nix flake check`.";
            default = [ ];
            type = with lib.types; listOf (attrsOf yaml.type);
          };
      in
      {
        arguments = lib.mkOption {
          description = "Arguments to `nix flake check`.";
          example = [ "--impure" ];
          default = [ ];
          type = with lib.types; listOf str;
        };
        preSteps = stepsOption "before";
        postSteps = stepsOption "after";
      };
  };

  config =
    let
      nixFlakeCheckCfg = config.ecosystems.github.workflows.${name};

      workflow = {
        name = "Evaluate the flake and run its checks";
        on = "push";
        permissions = { };
        concurrency = {
          cancel-in-progress = true;
          group = "\${{ github.workflow }}-$\{{ github.ref }}";
        };
        jobs.${name} = {
          name = "Check Nix flake";
          runs-on = "ubuntu-latest";
          steps = [
            {
              uses = "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1"; # v7.0.1
              "with".persist-credentials = false;
            }
            { uses = "cachix/install-nix-action@13d8dd58da0234aa297dedd986986ccb8e7f3e24"; } # v31.11.1
          ]
          ++ nixFlakeCheckCfg.preSteps
          ++ [
            {
              name = "Check flake";
              run =
                "nix flake check --print-build-logs"
                + lib.optionalString (
                  nixFlakeCheckCfg.arguments != [ ]
                ) " ${lib.escapeShellArgs nixFlakeCheckCfg.arguments}";
            }
          ]
          ++ nixFlakeCheckCfg.postSteps;
        };
      };

      workflowFile = (yaml.generate "github-workflow-${name}.yaml" workflow).overrideAttrs (old: {
        buildCommand = ''
          ${old.buildCommand}
          ${lib.getExe defaultsPkgs.actionlint} $out
          ${lib.getExe defaultsPkgs.zizmor} $out
          ${lib.getExe defaultsPkgs.yamlfmt} $out
        '';
      });
    in
    lib.mkIf config.ecosystems.github.enable {
      ecosystems.yaml.enable = true;

      files.file.".github/workflows/${name}.yaml".source = workflowFile;

      pre-commit.settings.hooks = {
        actionlint.enable = true;
        zizmor = {
          enable = true;
          package = defaultsPkgs.zizmor.wrap {
            settings.rules.ref-version-mismatch.ignore = [ "${name}.yaml" ];
          };
        };
      };
    };
}
