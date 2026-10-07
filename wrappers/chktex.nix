{
  config,
  dlib,
  lib,
  pkgs,
  wlib,
  ...
}:

# config file discovery through $CHKTEXRC/.chktexrc
let
  listType =
    let
      entry = lib.types.submodule {
        options = {
          ignoreCase = lib.mkEnableOption "ignore case" // {
            description = "Whether the values are case-insensitive";
          };
          override = lib.mkEnableOption "overriding" // {
            description = "Whether to override the list.";
          };
          values = lib.mkOption {
            description = "The values.";
            type = with lib.types; listOf str;
          };
        };
      };
    in
    lib.types.listOf entry;

  escapeChkTeX =
    builtins.replaceStrings
      [
        " "
        "\""
        "#"
        "!"
        "{"
        "}"
        "["
        "]"
        "="
        "\n"
        "\r"
        "\t"
      ]
      [
        "! "
        "!\""
        "!#"
        "!!"
        "!{"
        "!}"
        "!["
        "!]"
        "!="
        "!n"
        "!r"
        "!t"
      ];

  mkSetting =
    name: value:
    if builtins.isString value then
      "${name} = ${escapeChkTeX value}"
    else
      let
        entries = value;
        override = lib.any (e: e.override) entries;
        partitionByCaseSensitivity = lib.partition (e: e.ignoreCase) entries;
        caseSensitive = partitionByCaseSensitivity.wrong;
        caseInsensitive = partitionByCaseSensitivity.right;
        listValues =
          prefix: entries: suffix:
          let
            values = lib.pipe entries [
              (lib.concatMap (e: e.values))
              lib.naturalSort
              (map (v: "    ${escapeChkTeX v}"))
            ];
          in
          lib.optional (entries != [ ]) (lib.concatLines ([ prefix ] ++ values ++ [ suffix ]));
      in
      lib.concatStringsSep " " (
        [ name ]
        ++ lib.optional override "="
        ++ listValues "{" caseSensitive "}"
        ++ listValues "[" caseInsensitive "]"
      );
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `chktex`, written to `.chktexrc`.";
    default = { };
    type =
      with lib.types;
      let
        mkListType = vs: [ { values = vs; } ];
        list = coercedTo (listOf str) mkListType listType;
      in
      attrsOf (either str list);
  };

  config = {
    binName = "chktex";
    exePath = "bin/chktex";
    package = pkgs.texliveMinimal.withPackages (ps: [ ps.chktex ]);

    env.CHKTEXRC = lib.mkIf (config.settings != { }) (
      pkgs.writeTextDir ".chktexrc" (lib.concatMapAttrsStringSep "" mkSetting config.settings)
    );

    settings = dlib.mkDefault {
      CmdLine = [ "-v" ];
      WipeArg = [ "\\orcid:{}" ];
    };
  };
}
