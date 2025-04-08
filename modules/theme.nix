{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.programs.nixugen;

  mapAttrs' =
    f: attrs: (builtins.foldl' (acc: k: acc // (f k attrs.${k})) { } (builtins.attrNames attrs));
  flattenAttrs =
    attrs: sep: prefix:
    builtins.foldl' (
      acc: key:
      let
        val = attrs.${key};
      in
      if builtins.isAttrs val then
        acc // (flattenAttrs val sep "${prefix}${key}${sep}")
      else if key == "default" then
        acc // { "${lib.strings.removeSuffix sep prefix}" = val; }
      else
        acc // { "${prefix}${key}" = val; }
    ) { } (builtins.attrNames attrs);

  capitalize =
    str:
    let
      inherit (builtins) substring stringLength;
      firstChar = substring 0 1 str;
      restOfString = substring 1 (stringLength str) str;
    in
    lib.concatStrings [
      (lib.toUpper firstChar)
      restOfString
    ];

  applyThemePkg = (
    pkgs.writeShellApplication {
      name = "apply-theme";
      runtimeInputs = with pkgs; [ matugen ];
      text = ''
        CONFIG=${cfg.configHome}/matugen/config.toml
        ${pkgs.matugen}/bin/matugen image "$IMAGE" \
          --config "$CONFIG"
      '';
    }
  );
in
{
  options.programs.nixugen =
    let
      mkVarType =
        t:
        types.oneOf [
          t
          (types.attrsOf t)
        ];
    in
    {
      enable = mkEnableOption "The theme";

      harmonizedColors = mkOption {
        type = types.attrsOf (types.attrsOf (types.str));
        default = { };
      };

      customKeywords = mkOption {
        type = types.attrsOf (mkVarType types.str);
        default = { };
        description = "Extra vatiables to declare";
      };

      templates = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              inputPath = mkOption {
                type = types.path;
              };
              outputPath = mkOption {
                type = types.str;
              };
            };
          }
        );
        default = [ ];
      };

      initialOptions = {
        image = lib.mkOption {
          type = types.path;
          description = "Image as a color source";
        };

        mode = lib.mkOption {
          type = types.enum [
            "dark"
            "light"
            "amoled"
          ];
          default = "dark";
          description = "Mode of the theme (dark, light, amoled)";
        };

        scheme = mkOption {
          type = types.enum [
            "content"
            "expressive"
            "fidelity"
            "fruit-salad"
            "monochrome"
            "neutral"
            "rainbow"
            "tonal-spot"
          ];
          default = "tonal-spot";
          description = "The scheme of the theme";
        };

        contrast = mkOption {
          type = types.numbers.between (-1) 1;
          default = 0;
          apply = builtins.toString;
          description = "Use a modified contrast";
        };

        format = mkOption {
          type = types.enum [
            "rgb"
            "rgba"
            "hsl"
            "hsla"
            "hex"
            "strip"
          ];
          default = "strip";
          description = "Colors format";
        };
      };

      configHome = mkOption {
        type = types.path;
        default = /var/nixugen;
      };

      output = mkOption {
        inherit (pkgs.formats.json { }) type;
        readOnly = true;
        default = builtins.fromJSON (builtins.readFile "${themePkg}/theme.json");
        description = "Generated theme colors. Includes all variants.";
      };

      mutableOutput = {
        enable = mkEnableOption "Enable live updates feature";

        files = mkOption {
          type = types.path;
          readOnly = true;
          default = cfg.configHome;
        };

        symlinks = mkOption {
          type = types.attrsOf (types.str);
          default = { };
        };

        beforeChange = mkOption {
          type = types.str;
          default = "";
          description = "Run the script before the theme change";
        };

        afterChange = mkOption {
          type = types.str;
          default = "";
          description = "Run the script after the theme change";
        };
      };
    };

  config = lib.mkIf (cfg.enable && cfg.liveOutput.enable) {
    environment.packages = [
      applyThemePkg
    ];

    environment.file."${cfg.configHome}/matugen/config.toml".text =
      let
        harmonizedColors = lib.concatMapAttrs (_: category: category) cfg.harmonizedColors;
        customKeywords = flattenAttrs cfg.customKeywords "_" "";
        templates = builtins.mapAttrs (_: value: {
          mode = capitalize cfg.initialOptions.mode;
          input_path = builtins.toString value.inputPath;
          output_path = builtins.replaceStrings [ "$HOME" ] [ "~" ] value.outputPath;
        }) cfg.templates;
      in
      (pkgs.formats.toml { }).generate "config.toml" {
        config = {
          colors_to_harmonize = harmonizedColors;
          custom_keywords = customKeywords;
        };

        templates = templates;
      };
  };
}
