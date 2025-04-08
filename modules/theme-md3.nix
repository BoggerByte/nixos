{ inputs, config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.theme.md3;

  mapAttrs' = f: attrs: (builtins.foldl' (acc: k: acc // (f k attrs.${k})) {} (builtins.attrNames attrs));

  flattenAttrs = attrs: sep: prefix:
    builtins.foldl' (acc: key:
      let 
        val = attrs.${key};
      in 
      if builtins.isAttrs val then
        acc // (flattenAttrs val sep "${prefix}${key}${sep}")
      else if key == "default" then
        acc // { "${lib.strings.removeSuffix sep prefix}" = val; }
      else
        acc // { "${prefix}${key}" = val; }
    ) {} (builtins.attrNames attrs);

  capitalize = str: let
    inherit (builtins) substring stringLength;
    firstChar = substring 0 1 str;
    restOfString = substring 1 (stringLength str) str;
  in
    lib.concatStrings [(lib.toUpper firstChar) restOfString];

  harmonizedColors = lib.concatMapAttrs (_: category: category) cfg.harmonizedColors;

  customKeywords = flattenAttrs cfg.customKeywords "_" "";

  sanitizedTemplates = builtins.mapAttrs (_: value: {
    mode = capitalize cfg.dynamicColors.mode;
    input_path = builtins.toString value.inputPath;
    output_path = builtins.replaceStrings ["$HOME"] ["~"] value.outputPath;
  }) cfg.templates;

  matugenPkg = inputs.matugen.packages.${pkgs.system}.default;
  matugenConfigFormat = pkgs.formats.toml {};
  matugenConfig = matugenConfigFormat.generate "matugen.toml" {
    config = {
      reaload_apps = false;
      colors_to_harmonize = harmonizedColors;
      custom_keywords = customKeywords;
    };
    
    templates = sanitizedTemplates;
  };

  themeLiveDag = "theme-md3-live";
  themePkg = pkgs.runCommandLocal "theme-md3" {} ''
    mkdir -p $out
    cd $out
    export HOME=$out

    cp -f ${matugenConfig} matugen.toml

    IMAGE=${cfg.dynamicColors.image}
    MODE=${cfg.dynamicColors.mode}
    SCHEME=${cfg.dynamicColors.scheme}
    CONTRAST=${builtins.toString cfg.dynamicColors.contrast}
    FORMAT=${cfg.dynamicColors.format}

    ${matugenPkg}/bin/matugen image "$IMAGE" \
      ${if cfg.templates != {} then "--config matugen.toml" else ""} \
      --mode "$MODE" \
      --type "scheme-$SCHEME" \
      --contrast "$CONTRAST" \
      --json "$FORMAT" \
      --quiet \
      > "theme.json"
  '';

  themeSwitcherPkg = (pkgs.writeShellApplication {
    name = "theme-md3-switch";
    runtimeInputs = [ matugenPkg ];
    text = ''
      out=${cfg.live.files}

      mkdir -p $out
      cd $out
      export HOME=$out

      cp -f ${matugenConfig} matugen.toml

      IMAGE=''${IMAGE:-${cfg.dynamicColors.image}}
      MODE="${cfg.dynamicColors.mode}"
      SCHEME="${cfg.dynamicColors.scheme}"
      CONTRAST=${builtins.toString cfg.dynamicColors.contrast}
      FORMAT="${cfg.dynamicColors.format}"
    
      ${cfg.live.beforeChange}

      ${matugenPkg}/bin/matugen image "$IMAGE" \
        ${if cfg.templates != {} then "--config matugen.toml" else ""} \
        --mode "$MODE" \
        --type "scheme-$SCHEME" \
        --contrast "$CONTRAST" \
        --json "$FORMAT" \
        > "theme.json"

      ${pkgs.swww}/bin/swww img "$IMAGE"

      ${cfg.live.afterChange}
    '';
  });
in
{ 
  options.theme.md3 = let
    mkVarType = t: types.oneOf [ t (types.attrsOf t) ];
  in {
    enable = mkEnableOption "The MD3 theme";

    dynamicColors = {
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

    harmonizedColors = mkOption {
      type = types.attrsOf (types.attrsOf (types.str));
      default = {};
    };

    customKeywords = mkOption {
      type = types.attrsOf (mkVarType types.str);
      default = {};
      description = "Extra vatiables to declare";
    };

    templates = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          inputPath = mkOption {
            type = types.path;
          };
          outputPath = mkOption {
            type = types.str;
          };
        };
      });
      default = [];
    };

    files = mkOption {
      type = types.package;
      readOnly = true;
      default = themePkg;
      description = "Generated theme files. Including only the variant chosen.";
    };

    contents = mkOption {
      inherit (pkgs.formats.json {}) type;
      readOnly = true;
      default = builtins.fromJSON (builtins.readFile "${themePkg}/theme.json");
      description = "Generated theme colors. Includes all variants.";
    };

    live = {
      enable = mkEnableOption "Enable live updates feature";
      
      files = mkOption {
        type = types.path;
        default = "${config.xdg.cacheHome}/theme-md3";
      };

      symlinks = mkOption {
        type = types.attrsOf (types.str);
        default = {};
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

  config = lib.mkIf (cfg.enable && cfg.live.enable) {
    home.packages = [
      themeSwitcherPkg
    ];

    home.activation = lib.mkMerge [
      {
        ${themeLiveDag} = lib.hm.dag.entryAfter ["writeBoundary"] ''
          run rm -rf $VERBOSE_ARG ${cfg.live.files}
          run cp -r $VERBOSE_ARG ${themePkg} ${cfg.live.files}

          run find $VERBOSE_ARG ${cfg.live.files} -type d -exec chmod 744 {} \;
          run find $VERBOSE_ARG ${cfg.live.files} -type f -exec chmod 644 {} \;
        '';
      }
      
      (mapAttrs' (src: target: {
        "${themeLiveDag}-${src}-cleanup" = lib.hm.dag.entryBefore [themeLiveDag] ''
          target="${target}"

          run rm -if $VERBOSE_ARG "$target"
        '';

        "${themeLiveDag}-${src}-link" = lib.hm.dag.entryAfter [themeLiveDag] ''
          src="${src}"
          target="${target}"

          run mkdir -p $VERBOSE_ARG "''${target%/*}"
          run ln -s $VERBOSE_ARG "${config.theme.md3.live.files}/$src" "$target"
        '';
      }) cfg.live.symlinks)
    ];
  };
}