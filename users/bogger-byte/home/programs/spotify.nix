{ inputs, config, pkgs, lib, ... }:
let
  theme = config.theme.md3.contents;
in
{
  imports = [ 
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #   "spotify"
  # ];

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;

    theme = spicePkgs.themes.onepunch;
    
    colorScheme = "custom";
    customColorScheme = with theme.colors.dark; {
      text      = on_surface;
      subtext   = on_primary_container;
      extratext = on_surface_variant;

      main       = surface;
      sidebar    = surface;
      player     = surface;
      sec-player = surface_container;
      card       = surface_container;
      sec-card   = tertiary;

      shadow = surface;

      selected-row = primary;
      tab-active   = tertiary;

      button          = primary;
      button-active   = primary;
      button-disabled = secondary;

      notification       = tertiary;
      notification-error = error;
      
      misc = tertiary_container;      
    };

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];
  };
}