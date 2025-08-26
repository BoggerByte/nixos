{ inputs, pkgs, ... }:
let 
  pkgsHyprwm = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.hyprland.enable = true;
  programs.hyprland.package = pkgsHyprwm.hyprland;
  programs.hyprland.portalPackage = pkgsHyprwm.xdg-desktop-portal-hyprland;
  programs.hyprland.withUWSM  = true;

  # enable caching
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}