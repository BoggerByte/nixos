{ inputs, lib, config, ... }:

{
  imports = [
    ./theme
    ./programs
    ./shell/zsh
    ./bar/waybar
    ./wm/hyprland
    ./widgets/gtk
    ./widgets/rofi
    ./fonts.nix
  ];

  programs.home-manager.enable = true;

  services.udiskie.enable = true;

  home.stateVersion = "23.11";

  lib.meta = rec {
    configPath = "/etc/nixos";
    
    mkMutableSymlink = path: config.lib.file.mkOutOfStoreSymlink 
      (configPath + lib.strings.removePrefix (toString inputs.self) (toString path));
  };
}
