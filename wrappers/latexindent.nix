{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = pkgs.formats.yaml_1_2 { };

  # latexindent's YAML parser YAML::Tiny can not parse double-quoted multiline
  # strings with escaping. However, this is what `formats.yaml_1_2` generates.
  # Hence, bypass `formats.yaml_1_2` and call remarshal directly with the
  # `--yaml-style-newline="|"` option to render multiline strings as block
  # literals.
  #
  # See https://github.com/NixOS/nixpkgs/issues/465776 for more information.
  configFile =
    pkgs.runCommand "latexindent.yaml"
      {
        nativeBuildInputs = [ pkgs.remarshal ];
        inherit (config) settings;
        preferLocalBuild = true;
        __structuredAttrs = true;
      }
      ''
        json2yaml --yaml-style-newline="|" "$NIX_ATTRS_JSON_FILE" --unwrap=settings "$out"
      '';
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `latexindent`, written to `latexindent.yaml`.";
    default = { };
    inherit (yaml) type;
    apply = lib.mapAttrsRecursive (_: v: if builtins.isBool v then if v then 1 else 0 else v);
  };

  config = {
    flags = {
      "--local" = lib.mkIf (config.settings != { }) configFile;
      "--modifylinebreaks" = lib.mkDefault true;
    };
    package = pkgs.texlivePackages.latexindent;

    settings = {
      defaultIndent = "    ";
      removeTrailingWhitespace.beforeProcessing = true;
      noAdditionalIndentGlobal.keyEqualsValuesBracesBrackets = true;
      modifyLineBreaks = {
        condenseMultipleBlankLinesInto = true;
        oneSentencePerLine.manipulateSentences = true;
        environments = {
          BeginStartsOnOwnLine = 1;
          BodyStartsOnOwnLine = 1;
          EndStartsOnOwnLine = 1;
          EndFinishesWithLineBreak = 1;
          DBSFinishesWithLineBreak = 1;
        };
        ifelsefi = {
          IfStartsOnOwnLine = 1;
          BodyStartsOnOwnLine = 1;
          OrStartsOnOwnLine = 1;
          OrFinishesWithLineBreak = 1;
          ElseStartsOnOwnLine = 1;
          ElseFinishesWithLineBreak = 1;
          FiStartsOnOwnLine = 1;
          FiFinishesWithLineBreak = 1;
        };
        optionalArguments.LSqBStartsOnOwnLine = -1;
        mandatoryArguments.LCuBStartsOnOwnLine = -1;
        keyEqualsValuesBracesBrackets.EqualsStartsOnOwnLine = -1;
        items.ItemStartsOnOwnLine = 1;
        specialBeginEnd = {
          SpecialBeginStartsOnOwnLine = 1;
          SpecialBodyStartsOnOwnLine = 1;
          SpecialMiddleStartsOnOwnLine = 1;
          SpecialMiddleFinishesWithLineBreak = 1;
          SpecialEndStartsOnOwnLine = 1;
          SpecialEndFinishesWithLineBreak = 1;
          inlineMath = {
            SpecialBeginStartsOnOwnLine = -1;
            SpecialBodyStartsOnOwnLine = -1;
            SpecialEndStartsOnOwnLine = -1;
            SpecialEndFinishesWithLineBreak = -1;
          };
        };
        verbatim = {
          VerbatimBeginStartsOnOwnLine = 1;
          VerbatimEndFinishesWithLineBreak = 1;
        };
      };
      fineTuning.modifyLineBreaks.betterFullStop = ''
        (?x)                # ignore spaces and comments in the below
        \.                  # .
        (?!                 # not *followed by*
          (?:               #
              [a-zA-Z0-9]   # letters or digits
            | \\@           # \@
            | \),           # ),
            | \)\.          # ).
          )                 #
        )                   #
      '';
    };
  };
}
