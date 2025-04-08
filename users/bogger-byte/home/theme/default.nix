{ inputs, config, pkgs, lib, ... }:
let
  templatesDir = ./templates;
  templateFiles = builtins.attrNames (builtins.readDir templatesDir); 
in
{
  imports = [
    (inputs.self + "/modules/theme-md3.nix")
  ];

  home.packages = with pkgs; [ 
    inputs.matugen.packages.${pkgs.system}.default
  ];

  theme.md3 = {
    enable = true;

    dynamicColors = {
      image = (inputs.self + "/theme/wallpaper.png");
    };

    harmonizedColors = {
      semantic = {
        danger = "#ff0000";
        warning = "#cfb619";
        success = "#35bd26";
        info = "#0000ff";
      };

      ansi = {
        white = "#ffffff";
        black = "#000000";
        red = "#ff0000";
        green = "#00ff00";
        yellow = "#ffff00";
        orange = "#ff8000";
        blue = "#0000ff";
        magenta = "#ff00ff";
        cyan = "#00ffff";
      };
    };

    customKeywords = {
      font = {
        mono = "JetBrains Mono Nerd Font";
      };
      transparency = {
        default = "0.8";
        low = "0.9";
        high = "0.7";
      };
      blur = "3";
      border = "2";
      rounding = "10";
      spacing = {
        "1" = "5";
        "2" = "10";
        "3" = "15";
      };
    };

    templates =  builtins.listToAttrs (map (filename: {
      name = filename;
      value = {
        inputPath = "${templatesDir}/${filename}";
        outputPath = "~/theme/${filename}";
      };
    }) templateFiles);

    live = {
      enable = true;

      symlinks = {
        "theme/config.mako" = "${config.xdg.configHome}/mako/config";
      };

      # beforeChange = '''';

      afterChange = ''
        ${pkgs.mako}/bin/makoctl reload

        GTK_THEME=$(${pkgs.glib}/bin/gsettings get org.gnome.desktop.interface gtk-theme)
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme ""
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"

        ${pkgs.libnotify}/bin/notify-send "Theme changed!"
      '';
    };    
  };
}