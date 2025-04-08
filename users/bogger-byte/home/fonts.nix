{ pkgs, ... }: 

{
  home.packages = with pkgs; [ 
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
  fonts.fontconfig.enable = true;
} 
