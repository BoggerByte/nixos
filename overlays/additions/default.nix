{ pkgs ? import <nixpkgs> { } }:

{
  plymouth-minecraft-theme = pkgs.callPackage ./plymouth-minecraft-theme.nix { };
}
