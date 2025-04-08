{ config, pkgs, lib, ... }:

{
  services.mako.enable = true;
  xdg.configFile."mako/config".enable = false;
}