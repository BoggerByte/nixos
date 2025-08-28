{ config, pkgs, ... }:

{ 
  programs.waybar.enable = true;
  programs.waybar.settings = {
    mainBar = builtins.fromJSON (builtins.readFile ./src/config.jsonc);
  };
  programs.waybar.style = builtins.readFile ./src/style.css;

  home.file."${config.xdg.configHome}/waybar/variables.css".text = ''
    @import url("${config.theme.md3.live.files}/theme/colors.gtk3.css");
  '';

  # network / bluetooth applets
  home.packages = with pkgs; [
    networkmanagerapplet
    gnome-network-displays
  ];
}