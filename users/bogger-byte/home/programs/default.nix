{ pkgs, inputs, ... }:

{
  imports = [
    # ./discord
    ./btop.nix
    ./git.nix
    ./spotify.nix
    ./alacritty.nix
    ./mako.nix
    ./clipboard.nix
  ];

  home.packages = with pkgs; [
    nh
    openssl
    dconf

    lazydocker
    docker-slim
    ngrok

    brave
    telegram-desktop
    zoom-us

    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.goland

    libnotify
    gparted

    rustup
    bun
    nodejs_20 # LTS
    jdk21_headless # LTS
    python312
    gnumake

    nixd
    nixfmt-rfc-style
    hyprls

    networkmanagerapplet
    gnome-network-displays

    inputs.zen-browser.packages."${system}".default
  ];

  programs.zathura.enable = true;
  programs.vscode.enable = true;
  services.polkit-gnome.enable = true;

  programs.poetry.enable = true;
  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
  };
}