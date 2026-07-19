{
  config,
  lib,
  pkgs,
  ...
}:

let
  yaml = pkgs.formats.yaml { };
in
{
  options.ecosystems.github = {
    enable = lib.mkEnableOption "tools for GitHub development";

    workflows.nix-flake-check =
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
      nixFlakeCheckCfg = config.ecosystems.github.workflows.nix-flake-check;

      workflow = {
        name = "Evaluate the flake and run its checks";
        on = "push";
        jobs.nix-flake-check = {
          runs-on = "ubuntu-latest";
          permissions = { };
          steps = [
            { uses = "actions/checkout@v7"; }
            { uses = "cachix/install-nix-action@v31"; }
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

      workflowFile =
        (yaml.generate "github-workflow-nix-flake-check.yaml" workflow).overrideAttrs
          (oldAttrs: {
            buildCommand = ''
              ${oldAttrs.buildCommand}
              ${lib.getExe pkgs.actionlint} $out
              ${lib.getExe pkgs.yamlfmt} $out
            '';
          });

      writeWorkflowFile = pkgs.writers.writeBash "write-github-workflow-nix-flake-check" ''
        mkdir -p .github/workflows
        cat ${workflowFile} >.github/workflows/nix-flake-check.yaml
      '';
    in
    lib.mkIf config.ecosystems.github.enable {
      make-shells.default.shellHook = "${writeWorkflowFile}";

      pre-commit.settings.hooks = {
        actionlint.enable = true;
        write-github-workflow = {
          enable = true;
          name = "write-github-workflow";
          pass_filenames = false;
          always_run = true;
          description = "Write the GitHub workflow `nix flake check`";
          entry = "${writeWorkflowFile}";
        };
      };
    };
}
