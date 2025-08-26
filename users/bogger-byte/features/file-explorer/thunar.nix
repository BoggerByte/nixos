{ pkgs, ... }:

{
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  programs.xfconf.enable = true;
  services.gvfs.enable = true;    # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
}