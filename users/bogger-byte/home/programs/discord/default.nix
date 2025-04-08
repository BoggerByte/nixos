{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    discord
    betterdiscordctl
  ];

  home.activation."better-discord" = lib.hm.dag.entryAfter ["writeBoundary"] ''
    betterdiscord_injected=$(${pkgs.betterdiscordctl}/bin/betterdiscordctl status | ${pkgs.gnugrep}/bin/grep "injected: yes") || true

    if [ -z "$betterdiscord_injected" ]; then
      run ${pkgs.betterdiscordctl}/bin/betterdiscordctl install $VERBOSE_ARG
    fi
  '';

  xdg.configFile."BetterDiscord/plugins/NoSpotifyPause.plugin.js".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/bepvte/bd-addons/main/plugins/NoSpotifyPause.plugin.js";
    sha256 = "0h5wvaz46w00izvnhgkza14sr1pxsy97pmhyy9w26ig1hp16v8lb";
  };

  xdg.configFile."BetterDiscord/plugins/0PluginLibrary.plugin.js".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rauenzi/BDPluginLibrary/99d49cd7a5041c8f7552e79df9cec88670cce36c/release/0PluginLibrary.plugin.js";
    sha256 = "1laih8m8lp1yddzplmjjmad3h80qyg3f2z6hrwps20i5b4rri0ff";
  };

  xdg.configFile."BetterDiscord/themes/variables.css".text = ''
    @import "${config.theme.md3.live.files}/theme/colors.css";
  '';
  xdg.configFile."BetterDiscord/themes/MaterialDiscord.theme.css".source = ./src/MaterialDiscord.theme.css;
}