{ inputs, config, pkgs, ... }:
let
  profileName = "boggerbyte";
  theme = config.theme.md3.contents;

  nebulaVersion = "v3.1";
  nebula = pkgs.fetchzip {
    url = "https://github.com/JustAdumbPrsn/Zen-Nebula/releases/download/${nebulaVersion}/chrome.zip";
    sha256 = "sha256-HyWAExoXBRRuDo49Ft+kYVkBQmJz14tdp5CDyVBUygI=";
  };
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser.enable = true;
  programs.zen-browser.policies = let
    mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      installation_mode = "force_installed";
    });
  in {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = false;
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
    ExtensionSettings = mkExtensionSettings {
      "extension@ublock.com" = "ublock-origin";
    };
  };
  programs.zen-browser.profiles.${profileName} = {
    settings = {
      "zen.welcome-screen.seen" = true;
      "zen.theme.accent-color" = "#${theme.colors.dark.primary}";
    };
    # spaces = {
    #   dev = {
    #     id = "550e8400-e29b-41d4-a716-446655440000";
    #     position = 1;
    #     icon = "💻";
    #     container = 2;

    #     theme = {
    #       type = "gradient";
    #       opacity = 0.5;
    #       rotation = 45;
    #       texture = 0.3;

    #       colors = [
    #         (let
    #           primary = parseHex theme.colors.dark.primary;
    #         in {
    #           red = primary.r;
    #           green = primary.g;
    #           blue = primary.b;
    #           custom = true;
    #           algorithm = "complementary";
    #           primary = true;
    #           lightness = 20;
    #           position.x = 0;
    #           position.y = 0;
    #           type = "explicit-lightness";
    #         })
    #         (let
    #           surface = parseHex theme.colors.dark.surface;
    #         in {
    #           red = surface.r;
    #           green = surface.g;
    #           blue = surface.b;
    #           custom = false;
    #           algorithm = "analogous";
    #           primary = false;
    #           lightness = -10;
    #           position.x = 100;
    #           position.y = 0;
    #           type = "undefined";
    #         })
    #       ];
    #     };
    #   };

    #   docs = {
    #     id = "f47ac10b-58cc-4372-a567-0e02b2c3d479";
    #     position = 2;
    #     icon = "📖";
    #     container = null;

    #     theme = {
    #       type = "gradient";
    #       opacity = 0.5;
    #       rotation = null;
    #       texture = 0.0;
    #       colors = [];
    #     };
    #   };
    # };
  };

  home.file.".zen/${profileName}/chrome" = {
    source = "${nebula}/";
    recursive = true;
  };
}