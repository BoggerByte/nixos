{ config, pkgs, ... }: 

{
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    general.import = [
      "${config.theme.md3.live.files}/theme/config.alacritty.toml"
    ];

    font.size = 14;
  };
}