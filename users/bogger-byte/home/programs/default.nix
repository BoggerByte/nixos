{ pkgs, ... }:

{
  imports = [
    # ./discord
    ./btop.nix
    ./git.nix
    ./spotify.nix
    ./alacritty.nix
    ./mako.nix
    ./vscode
    ./zen-browser
  ];

  home.packages = with pkgs; [
    brave
    google-chrome
    telegram-desktop
    zoom-us

    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.goland

    lazydocker
    docker-slim
    ngrok
  ];

  programs.zathura.enable = true;
  services.polkit-gnome.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
}
