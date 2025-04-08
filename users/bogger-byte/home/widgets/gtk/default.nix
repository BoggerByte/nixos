{ config, pkgs, lib, ... }: 

{
  qt = {
    enable = true;
    platformTheme.name = "gnome";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
    };
    font = {
      name = config.theme.md3.customKeywords.font.mono;
      size = 10;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 18;
  };

  home.sessionVariables.XCURSOR_SIZE = 18;

  home.file."${config.xdg.configHome}/gtk-3.0/gtk.css" = lib.mkForce {
    source = ./src/gtk3.css;
  };

  home.file."${config.xdg.configHome}/gtk-3.0/colors.css".text = ''
    @import "${config.theme.md3.live.files}/theme/colors.gtk3.css";
  '';

  home.file."${config.xdg.configHome}/gtk-4.0/gtk.css" = lib.mkForce {
    source = ./src/gtk4.css;
  };

  home.file."${config.xdg.configHome}/gtk-4.0/colors.css".text = ''
    @import "${config.theme.md3.live.files}/theme/colors.css";
  '';
}