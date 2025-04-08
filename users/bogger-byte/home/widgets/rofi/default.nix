{ config, pkgs, lib, ... }: 

{
  programs.rofi.enable = true;
  programs.rofi.package = pkgs.rofi-wayland;
  programs.rofi.plugins = [ pkgs.rofi-emoji-wayland ];

  home.file."${config.xdg.configHome}/rofi/config.rasi" = {
    source = config.lib.meta.mkMutableSymlink ./src/config.rasi;
  };

  home.file."${config.xdg.configHome}/rofi/launcher.rasi" = {
    source = config.lib.meta.mkMutableSymlink ./src/launcher.rasi;
  };

  home.file."${config.xdg.configHome}/rofi/shared/fonts.rasi" = {
    source = config.lib.meta.mkMutableSymlink ./src/shared/fonts.rasi;
  };

  home.file."${config.xdg.configHome}/rofi/shared/colors.rasi".text = ''
    @import "${config.theme.md3.live.files}/theme/colors.rasi"
  '';
}