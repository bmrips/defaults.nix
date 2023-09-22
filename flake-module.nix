{
  lib,
  flake-parts-lib,
  ...
}:

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    let
      mkEnableDefaultsOption = ecosystem: lib.mkEnableOption "defaults for ${ecosystem} development.";
    in
    {
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
        tools = {
          bash.enable = mkEnableDefaultsOption "Bash";
          editorconfig.enable = mkEnableDefaultsOption "EditorConfig";
          github.enable = mkEnableDefaultsOption "GitHub";
          haskell.enable = mkEnableDefaultsOption "Haskell";
          latex.enable = mkEnableDefaultsOption "LaTeX";
          lua.enable = mkEnableDefaultsOption "Lua";
          markdown.enable = mkEnableDefaultsOption "Markdown";
          nix.enable = mkEnableDefaultsOption "Nix" // {
            default = true;
          };
          sops.enable = mkEnableDefaultsOption "SOPS";
          toml.enable = mkEnableDefaultsOption "TOML";
          yaml.enable = mkEnableDefaultsOption "YAML";
        };
      };

      config = lib.mkMerge [

        {
          defaults.devShell = pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];
            inherit (config.defaults) packages shellHook;
          };

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
              statix.settings.format = "stderr";
              treefmt.enable = true;
              trim-trailing-whitespace.enable = true;
              typos.enable = true;
            };
          };

          treefmt.flakeCheck =
            !config.pre-commit.settings.enable || !config.pre-commit.settings.hooks.treefmt.enable;

          treefmt.programs = {
            mdformat.settings.wrap = "no";
            nixf-diagnose.ignore = [ "sema-primop-overridden" ];
            shfmt.indent_size = 4;
            stylua.settings = {
              call_parentheses = "None";
              column_width = 100;
              indent_type = "Spaces";
              indent_width = 2;
              quote_style = "AutoPreferSingle";
            };
          };
        }

        (lib.mkIf config.defaults.tools.bash.enable {
          defaults.packages = [ pkgs.checkbashisms ];
          pre-commit.settings.hooks = {
            check-executables-have-shebangs.enable = true;
            check-shebang-scripts-are-executable.enable = true;
          };
          treefmt.programs.shfmt.enable = true;
        })

        (lib.mkIf config.defaults.tools.github.enable {
          defaults.tools.yaml.enable = true; # for `.github/`
          pre-commit.settings.hooks.actionlint.enable = true;
        })

        (lib.mkIf config.defaults.tools.haskell.enable {
          defaults.tools.yaml.enable = true; # for `fourmolu.yaml`
          pre-commit.settings.hooks.hlint.enable = true;
          treefmt.programs = {
            cabal-gild.enable = true;
            fourmolu.enable = true;
          };
        })

        (lib.mkIf config.defaults.tools.lua.enable {
          defaults.tools = {
            toml.enable = true; # for `selene.toml`
            yaml.enable = true; # for `<std>.yaml`
          };
          pre-commit.settings.hooks.selene.enable = true;
          treefmt.programs.stylua.enable = true;
        })

        (lib.mkIf config.defaults.tools.markdown.enable {
          defaults.tools.yaml.enable = true; # for `.markdownlint.yaml`
          pre-commit.settings.hooks.markdownlint.enable = true;
          treefmt.programs.mdformat.enable = true;
        })

        (lib.mkIf config.defaults.tools.nix.enable {
          pre-commit.settings.hooks = {
            deadnix.enable = true;
            statix.enable = true;
          };
          treefmt.programs = {
            nixf-diagnose.enable = true;
            nixfmt.enable = true;
          };
        })

        (lib.mkIf config.defaults.tools.sops.enable {
          defaults = {
            packages = [ pkgs.sops ];
            shellHook = /* bash */ ''
              git config diff.sops.textconv "sops decrypt"
            '';
            tools.yaml.enable = true; # for `.sops.yaml`
          };
        })

        (lib.mkIf config.defaults.tools.toml.enable {
          pre-commit.settings.hooks.check-toml.enable = true;
        })

        (lib.mkIf config.defaults.tools.yaml.enable {
          defaults.packages = [ pkgs.yq-go ];
          pre-commit.settings.hooks = {
            check-yaml.enable = true;
            yamllint.enable = true;
          };
          treefmt.programs.yamlfmt.enable = true;
        })

      ];
    }
  );
}
